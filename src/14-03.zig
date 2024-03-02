/// MySQL API demo
/// https://dev.mysql.com/doc/c-api/8.0/en/
///
///
const std = @import("std");
const c = @cImport({
    @cInclude("mysql.h");
});
const exit = std.os.exit;
const print = std.debug.print;

pub const DB_INFO = struct {
    host: [:0]const u8 = "localhost",
    user: [:0]const u8 = "root",
    password: [:0]const u8 = "password",
    database: [:0]const u8 = "test",
    port: u32 = 3306,
};

pub const DB = struct {
    conn: *c.MYSQL,

    fn init(db_info: DB_INFO) !DB {
        const db = c.mysql_init(null);

        if (db == null) {
            return error.initError;
        }

        if (c.mysql_real_connect(
            db,
            db_info.host,
            db_info.user,
            db_info.password,
            db_info.database,
            db_info.port,
            null,
            0,
        ) == null) {
            return error.connectError;
        }

        return .{ .conn = db };
    }

    fn deinit(self: DB) void {
        _ = c.mysql_close(self.conn);

        return;
    }

    fn execute(self: DB, query: [:0]const u8) !void {
        var errorMessage: [*c]const u8 = undefined;

        if (c.mysql_query(self.conn, query) != 0) {
            errorMessage = c.mysql_error(self.conn);
            print("Exec query failed: {s}\n", .{errorMessage});

            return error.execError;
        }

        return;
    }

    fn queryTable(self: DB) !void {
        const result: *c.MYSQL_RES = c.mysql_store_result(self.conn);
        defer c.mysql_free_result(result);

        const query =
            \\ SELECT
            \\     c.name,
            \\     cc.name
            \\ FROM
            \\     cats c
            \\     INNER JOIN cat_colors cc ON cc.id = c.color_id;
            \\
        ;

        if (c.mysql_real_query(self.conn, query, query.len) != 0) {
            const errorMessage = c.mysql_error(self.conn);
            print("Query failed: {s}\n", .{errorMessage});

            return error.queryError;
        }

        while (c.mysql_fetch_row(result)) |row| {
            const cat_name = row[0];
            const color_name = row[1];

            print("Cat: {s}, Color: {s}\n", .{ cat_name, color_name });
        }
    }

    fn insertTable(self: DB) !void {
        const cat_colors = .{
            .{
                "Blue",
                .{ "Tigger", "Sammy" },
            },
            .{
                "Black",
                .{ "Oreo", "Biscuit" },
            },
        };

        const insert_color_stmt = blk: {
            const stmt: ?*c.MYSQL_STMT = c.mysql_stmt_init(self.conn);
            const insert_color_query = "INSERT INTO cat_colors (name) values (?)";

            defer _ = c.mysql_stmt_close(stmt);

            if (c.mysql_stmt_prepare(stmt, insert_color_query, insert_color_query.len) != 0) {
                print("Prepare stmt failed: {s}\n", .{c.mysql_error(self.conn)});

                return error.prepareStmt;
            }

            break :blk stmt.?;
        };

        const insert_cat_stmt = blk: {
            const stmt: ?*c.MYSQL_STMT = c.mysql_stmt_init(self.conn);
            const insert_cat_query = "INSERT INTO cats (name) values (?)";

            defer _ = c.mysql_stmt_close(stmt);

            if (c.mysql_stmt_prepare(stmt, insert_cat_query, insert_cat_query.len) != 0) {
                print("Prepare stmt failed: {s}\n", .{c.mysql_error(self.conn)});

                return error.prepareStmt;
            }

            break :blk stmt.?;
        };

        inline for (cat_colors) |row| {
            const color = row.@"0";
            const cat_names = row.@"1";

            var bind: *c.MYSQL_BIND = undefined;
            bind.buffer = @constCast(color);

            if (!c.mysql_stmt_bind_param(insert_color_stmt, bind)) {
                print("Bind param failed: {s}\n", .{c.mysql_error(self.conn)});

                return error.bindParamError;
            }

            if (c.mysql_stmt_execute(insert_color_stmt) != 0) {
                print("Exec stmt failed: {s}\n", .{c.mysql_error(self.conn)});

                return error.execStmtError;
            }

            _ = c.mysql_stmt_reset(insert_color_stmt);

            // const last_id = c.mysql_insert_id(self.conn);

            inline for (cat_names) |cat_name| {
                var params: *c.MYSQL_BIND = undefined;
                params.buffer = @constCast(cat_name);

                if (!c.mysql_stmt_bind_param(insert_cat_stmt, params)) {
                    print("Bind param failed: {s}\n", .{c.mysql_error(self.conn)});

                    return error.bindParamError;
                }

                if (c.mysql_stmt_execute(insert_cat_stmt) != 0) {
                    print("Exec stmt failed: {s}\n", .{c.mysql_error(self.conn)});

                    return error.execStmtError;
                }

                _ = c.mysql_stmt_reset(insert_cat_stmt);
            }
        }

        return;
    }
};

pub fn main() !void {
    const version = c.mysql_get_client_version();
    print("mysql version is {}\n", .{version});

    const info: DB_INFO = .{
        .database = "test",
        .host = "localhost",
        .user = "root",
        .password = "1234",
        .port = 3306,
    };

    const db = try DB.init(info);
    defer db.deinit();

    try db.execute(
        \\ CREATE TABLE IF NOT EXISTS cat_colors (
        \\  id INT AUTO_INCREMENT PRIMARY KEY,
        \\  name VARCHAR(255) NOT NULL UNIQUE
        \\);
    );
    try db.execute(
        \\CREATE TABLE IF NOT EXISTS cats (
        \\  id INT AUTO_INCREMENT PRIMARY KEY,
        \\  name VARCHAR(255) NOT NULL,
        \\  color_id INT NOT NULL,
        \\  CONSTRAINT fk_color
        \\    FOREIGN KEY (color_id) 
        \\    REFERENCES cat_colors(id)
        \\    ON DELETE RESTRICT
        \\    ON UPDATE CASCADE
        \\);
    );

    try db.insertTable();
    try db.queryTable();
}
