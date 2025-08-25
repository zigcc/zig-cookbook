/// SQLite API demo
/// https://www.sqlite.org/cintro.html
///
const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});
const print = std.debug.print;

const DB = struct {
    db: *c.sqlite3,

    fn init(db: *c.sqlite3) DB {
        return .{ .db = db };
    }

    fn deinit(self: DB) void {
        _ = c.sqlite3_close(self.db);
    }

    fn execute(self: DB, query: [:0]const u8) !void {
        var errmsg: [*c]u8 = undefined;
        if (c.SQLITE_OK != c.sqlite3_exec(self.db, query, null, null, &errmsg)) {
            defer c.sqlite3_free(errmsg);
            print("Exec query failed: {s}\n", .{errmsg});
            return error.execError;
        }
        return;
    }

    fn queryTable(self: DB) !void {
        const stmt = blk: {
            var stmt: ?*c.sqlite3_stmt = undefined;
            const query =
                \\ SELECT
                \\     c.name,
                \\     cc.name
                \\ FROM
                \\     cats c
                \\     INNER JOIN cat_colors cc ON cc.id = c.color_id;
                \\
            ;
            if (c.SQLITE_OK != c.sqlite3_prepare_v2(self.db, query, query.len + 1, &stmt, null)) {
                print("Can't create prepare statement: {s}\n", .{c.sqlite3_errmsg(self.db)});
                return error.prepareStmt;
            }
            break :blk stmt.?;
        };
        defer _ = c.sqlite3_finalize(stmt);

        var rc = c.sqlite3_step(stmt);
        while (rc == c.SQLITE_ROW) {
            // iCol is 0-based.
            // Those return text are invalidated when call step, reset, finalize are called
            // https://www.sqlite.org/c3ref/column_blob.html
            const cat_name = c.sqlite3_column_text(stmt, 0);
            const color_name = c.sqlite3_column_text(stmt, 1);

            print("Cat {s} is in {s} color\n", .{ cat_name, color_name });
            rc = c.sqlite3_step(stmt);
        }

        if (rc != c.SQLITE_DONE) {
            print("Step query failed: {s}\n", .{c.sqlite3_errmsg(self.db)});
            return error.stepQuery;
        }
    }

    fn insertTable(self: DB) !void {
        const insert_color_stmt = blk: {
            var stmt: ?*c.sqlite3_stmt = undefined;
            const query = "INSERT INTO cat_colors (name) values (?1)";
            if (c.SQLITE_OK != c.sqlite3_prepare_v2(self.db, query, query.len + 1, &stmt, null)) {
                print("Can't create prepare statement: {s}\n", .{c.sqlite3_errmsg(self.db)});
                return error.prepareStmt;
            }
            break :blk stmt.?;
        };
        defer _ = c.sqlite3_finalize(insert_color_stmt);

        const insert_cat_stmt = blk: {
            var stmt: ?*c.sqlite3_stmt = undefined;
            const query = "INSERT INTO cats (name, color_id) values (?1, ?2)";
            if (c.SQLITE_OK != c.sqlite3_prepare_v2(self.db, query, query.len + 1, &stmt, null)) {
                print("Can't create prepare statement: {s}\n", .{c.sqlite3_errmsg(self.db)});
                return error.prepareStmt;
            }
            break :blk stmt.?;
        };
        defer _ = c.sqlite3_finalize(insert_cat_stmt);

        const cat_colors = .{
            .{
                "Blue", .{
                    "Tigger",
                    "Sammy",
                },
            },
            .{
                "Black", .{
                    "Oreo",
                    "Biscuit",
                },
            },
        };

        inline for (cat_colors) |row| {
            const color = row.@"0";
            const cat_names = row.@"1";

            // bind index is 1-based.
            if (c.SQLITE_OK != c.sqlite3_bind_text(insert_color_stmt, 1, color, color.len, c.SQLITE_STATIC)) {
                print("Can't bind text: {s}\n", .{c.sqlite3_errmsg(self.db)});
                return error.bindText;
            }
            if (c.SQLITE_DONE != c.sqlite3_step(insert_color_stmt)) {
                print("Can't step color stmt: {s}\n", .{c.sqlite3_errmsg(self.db)});
                return error.step;
            }

            _ = c.sqlite3_reset(insert_color_stmt);

            const last_id = c.sqlite3_last_insert_rowid(self.db);
            inline for (cat_names) |cat_name| {
                if (c.SQLITE_OK != c.sqlite3_bind_text(insert_cat_stmt, 1, cat_name, cat_name.len, c.SQLITE_STATIC)) {
                    print("Can't bind cat name: {s}\n", .{c.sqlite3_errmsg(self.db)});
                    return error.bindText;
                }
                if (c.SQLITE_OK != c.sqlite3_bind_int64(insert_cat_stmt, 2, last_id)) {
                    print("Can't bind cat color_id: {s}\n", .{c.sqlite3_errmsg(self.db)});
                    return error.bindText;
                }
                if (c.SQLITE_DONE != c.sqlite3_step(insert_cat_stmt)) {
                    print("Can't step cat stmt: {s}\n", .{c.sqlite3_errmsg(self.db)});
                    return error.step;
                }

                _ = c.sqlite3_reset(insert_cat_stmt);
            }
        }

        return;
    }
};

pub fn main() !void {
    const version = c.sqlite3_libversion();
    print("libsqlite3 version is {s}\n", .{version});

    var c_db: ?*c.sqlite3 = undefined;
    if (c.SQLITE_OK != c.sqlite3_open(":memory:", &c_db)) {
        print("Can't open database: {s}\n", .{c.sqlite3_errmsg(c_db)});
        return;
    }
    const db = DB.init(c_db.?);
    defer db.deinit();

    try db.execute(
        \\ create table if not exists cat_colors (
        \\   id integer primary key,
        \\   name text not null unique
        \\ );
        \\ create table if not exists cats (
        \\   id integer primary key,
        \\   name text not null,
        \\   color_id integer not null references cat_colors(id)
        \\ );
    );

    try db.insertTable();
    try db.queryTable();
}
