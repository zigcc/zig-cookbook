/// MySQL API demo
/// https://dev.mysql.com/doc/c-api/8.0/en/
///
///
const std = @import("std");
const Allocator = std.mem.Allocator;
const c = @cImport({
    @cInclude("mysql.h");
});
const exit = std.os.exit;
const print = std.debug.print;
const err = std.log.err;

pub const DB_INFO = struct {
    host: [:0]const u8,
    user: [:0]const u8,
    password: [:0]const u8,
    database: [:0]const u8,
    port: u32 = 3306,
};

pub const DB = struct {
    conn: *c.MYSQL,
    allocator: Allocator,

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
            c.CLIENT_MULTI_STATEMENTS,
        ) == null) {
            err("Connect to database failed: {s}\n", .{c.mysql_error(db)});
            return error.connectError;
        }

        return .{ .conn = db, .allocator = std.heap.page_allocator };
    }

    fn deinit(self: DB) void {
        _ = c.mysql_close(self.conn);

        return;
    }

    fn execute(self: DB, query: []const u8) !void {
        if (c.mysql_real_query(self.conn, query.ptr, query.len) != 0) {
            err("Exec query failed: {s}\n", .{c.mysql_error(self.conn)});
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

        const insert_color_stmt: *c.MYSQL_STMT = blk: {
            const stmt = c.mysql_stmt_init(self.conn);
            const insert_color_query = "INSERT INTO cat_colors (name) values (?)";
            std.debug.print("stmt is {any}\n", .{stmt.?});

            // errdefer _ = c.mysql_stmt_close(stmt);
            const result = c.mysql_stmt_prepare(stmt, insert_color_query, insert_color_query.len);
            if (result != 0) {
                print("Prepare stmt failed: code:{d}, msg:{s}\n", .{
                    result,
                    c.mysql_error(self.conn),
                });

                return error.prepareStmt;
            }

            break :blk stmt.?;
        };

        const insert_cat_stmt: *c.MYSQL_STMT = blk: {
            const stmt: ?*c.MYSQL_STMT = c.mysql_stmt_init(self.conn);
            const insert_cat_query = "INSERT INTO cats (name, color_id) values (?, ?)";
            errdefer _ = c.mysql_stmt_close(stmt);
            if (c.mysql_stmt_prepare(stmt, insert_cat_query, insert_cat_query.len) != 0) {
                print("Prepare stmt failed: {s}\n", .{c.mysql_error(self.conn)});

                return error.prepareStmt;
            }

            break :blk stmt.?;
        };

        inline for (cat_colors) |row| {
            const color = row.@"0";
            const cat_names = row.@"1";

            var color_binds = [_]c.MYSQL_BIND{std.mem.zeroes(c.MYSQL_BIND)};
            color_binds[0].buffer_type = c.MYSQL_TYPE_STRING;
            color_binds[0].buffer_length = color.len;
            color_binds[0].is_null = 0;
            color_binds[0].buffer = @constCast(@ptrCast(&color));

            if (c.mysql_stmt_bind_param(insert_color_stmt, &color_binds)) {
                print("Bind param failed: {s}\n", .{c.mysql_error(self.conn)});
                return error.bindParamError;
            }

            if (c.mysql_stmt_execute(insert_color_stmt) == 0) {
                print("Exec stmt failed: {s}\n", .{c.mysql_error(self.conn)});

                return error.execStmtError;
            }

            _ = c.mysql_stmt_reset(insert_color_stmt);

            const last_id = c.mysql_insert_id(self.conn);

            inline for (cat_names) |cat_name| {
                var bindParams: [*c]c.MYSQL_BIND = @as([*c]c.MYSQL_BIND, @ptrCast(@alignCast(c.malloc(@sizeOf(c.MYSQL_BIND) *% @as(c_ulong, 2)))));

                const cat_name_buf = @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@constCast(@alignCast(cat_name))))));
                const last_id_buf = @as(?*anyopaque, @ptrCast(@as([*c]u8, @ptrCast(@constCast(@alignCast(&last_id))))));

                bindParams[0].buffer_type = c.MYSQL_TYPE_STRING;
                bindParams[0].length = (@as(c_ulong, 1));
                bindParams[0].is_null = 0;
                bindParams[0].buffer = cat_name_buf;

                bindParams[1].buffer_type = c.MYSQL_TYPE_STRING;
                bindParams[1].length = (@as(c_ulong, 1));
                bindParams[1].is_null = 0;
                bindParams[1].buffer = last_id_buf;

                if (c.mysql_stmt_bind_param(insert_cat_stmt, bindParams)) {
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
        .database = "public",
        .host = "127.0.0.1",
        .user = "root",
        .password = "123",
    };

    const db = try DB.init(info);
    defer db.deinit();

    try db.execute(
        \\ CREATE TABLE IF NOT EXISTS cat_colors (
        \\  id INT AUTO_INCREMENT PRIMARY KEY,
        \\  name VARCHAR(255) NOT NULL
        \\);
        \\
        \\CREATE TABLE IF NOT EXISTS cats (
        \\  id INT AUTO_INCREMENT PRIMARY KEY,
        \\  name VARCHAR(255) NOT NULL,
        \\  color_id INT NOT NULL
        \\)
    );
    // Since we use multi-statement, we need to consume all results.
    // Otherwise we will get following error when we execute next query.
    // Commands out of sync; you can't run this command now
    //
    // https://dev.mysql.com/doc/c-api/8.0/en/mysql-next-result.html
    while (c.mysql_next_result(db.conn) == 0) {
        const res = c.mysql_store_result(db.conn);
        c.mysql_free_result(res);
    }

    try db.insertTable();
    try db.queryTable();
}
