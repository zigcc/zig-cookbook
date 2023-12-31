# Postgres

As with [previous section](./14-01-sqlite.md), here we introduce [libpq](https://www.postgresql.org/docs/16/libpq-example.html) interface directly, other than [wrapper package](https://github.com/tonis2/zig-postgres).

Data models used in demo are the same with the one used in [SQLite section](./14-01-sqlite.md).

> Note: After execute a query with `PQexec` like functions, if there are returning results, check the result with `PGRES_TUPLES_OK`, otherwise `PGRES_COMMAND_OK` should be used.
- <https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESULTSTATUS>

```zig
const std = @import("std");
const print = std.debug.print;
const c = @cImport({
    @cInclude("libpq-fe.h");
});

const DB = struct {
    conn: *c.PGconn,

    fn init(conn_info: [:0]const u8) !DB {
        const conn = c.PQconnectdb(conn_info);
        if (c.PQstatus(conn) != c.CONNECTION_OK) {
            print("Connect failed, err: {s}\n", .{c.PQerrorMessage(conn)});
            return error.connect;
        }
        return DB{ .conn = conn.? };
    }

    fn deinit(self: DB) void {
        c.PQfinish(self.conn);
    }

    // Execute a query without returning any data.
    fn exec(self: DB, query: [:0]const u8) !void {
        const result = c.PQexec(self.conn, query);
        defer c.PQclear(result);

        if (c.PQresultStatus(result) != c.PGRES_COMMAND_OK) {
            print("exec query failed, query:{s}, err: {s}\n", .{ query, c.PQerrorMessage(self.conn) });
            return error.Exec;
        }
    }

    fn insertTable(self: DB) !void {
        // 1. create two prepared statements.
        {
            // There is no `get_last_insert_rowid` in libpq, so we use RETURNING id to get the last insert id.
            const res = c.PQprepare(
                self.conn,
                "insert_cat_colors",
                "INSERT INTO cat_colors (name) VALUES ($1) returning id",
                1, // nParams, number of parameters supplied
                // Specifies, by OID, the data types to be assigned to the parameter symbols.
                // When null, the server infers a data type for the parameter symbol in the same way it would do for an untyped literal string.
                null, // paramTypes.
            );
            defer c.PQclear(res);
            if (c.PQresultStatus(res) != c.PGRES_COMMAND_OK) {
                print("prepare insert cat_colors failed, err: {s}\n", .{c.PQerrorMessage(self.conn)});
                return error.prepare;
            }
        }
        {
            const res = c.PQprepare(self.conn, "insert_cats", "INSERT INTO cats (name, color_id) VALUES ($1, $2)", 2, null);
            defer c.PQclear(res);
            if (c.PQresultStatus(res) != c.PGRES_COMMAND_OK) {
                print("prepare insert cats failed, err: {s}\n", .{c.PQerrorMessage(self.conn)});
                return error.prepare;
            }
        }
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

        // 2. Use prepared statements to insert data.
        inline for (cat_colors) |row| {
            const color = row.@"0";
            const cat_names = row.@"1";
            const color_id = blk: {
                const res = c.PQexecPrepared(
                    self.conn,
                    "insert_cat_colors",
                    1, // nParams
                    &[_][*c]const u8{color}, // paramValues
                    &[_]c_int{color.len}, // paramLengths
                    &[_]c_int{0}, // paramFormats
                    0, // resultFormat
                );
                defer c.PQclear(res);

                // Since this insert has returns, so we check res with PGRES_TUPLES_OK
                if (c.PQresultStatus(res) != c.PGRES_TUPLES_OK) {
                    print("exec insert cat_colors failed, err: {s}\n", .{c.PQresultErrorMessage(res)});
                    return error.InsertCatColors;
                }
                break :blk std.mem.span(c.PQgetvalue(res, 0, 0));
            };
            inline for (cat_names) |name| {
                const res = c.PQexecPrepared(
                    self.conn,
                    "insert_cats",
                    2, // nParams
                    &[_][*c]const u8{ name, color_id }, // paramValues
                    &[_]c_int{ name.len, @intCast(color_id.len) }, // paramLengths
                    &[_]c_int{ 0, 0 }, // paramFormats
                    0, // resultFormat, 0 means text, 1 means binary.
                );
                defer c.PQclear(res);

                // This insert has no returns, so we check res with PGRES_COMMAND_OK
                if (c.PQresultStatus(res) != c.PGRES_COMMAND_OK) {
                    print("exec insert cats failed, err: {s}\n", .{c.PQresultErrorMessage(res)});
                    return error.InsertCats;
                }
            }
        }
    }

    fn queryTable(self: DB) !void {
        const query =
            \\ SELECT
            \\     c.name,
            \\     cc.name
            \\ FROM
            \\     cats c
            \\     INNER JOIN cat_colors cc ON cc.id = c.color_id;
            \\
        ;

        const result = c.PQexec(self.conn, query);
        defer c.PQclear(result);

        if (c.PQresultStatus(result) != c.PGRES_TUPLES_OK) {
            print("exec query failed, query:{s}, err: {s}\n", .{ query, c.PQerrorMessage(self.conn) });
            return error.queryTable;
        }

        const num_rows = c.PQntuples(result);
        for (0..@intCast(num_rows)) |row| {
            const cat_name = std.mem.span(c.PQgetvalue(result, @intCast(row), 0));
            const color_name = std.mem.span(c.PQgetvalue(result, @intCast(row), 1));
            print("Cat {s} is in {s} color\n", .{ cat_name, color_name });
        }
    }
};

pub fn main() !void {
    const conn_info = "host=127.0.0.1 user=postgres password=postgres dbname=postgres";

    const db = try DB.init(conn_info);
    defer db.deinit();

    try db.exec(
        \\ create table if not exists cat_colors (
        \\   id integer primary key generated always as identity,
        \\   name text not null unique
        \\ );
        \\ create table if not exists cats (
        \\   id integer primary key generated always as identity,
        \\   name text not null,
        \\   color_id integer not null references cat_colors(id)
        \\ );
    );

    try db.insertTable();
    try db.queryTable();
}
```
