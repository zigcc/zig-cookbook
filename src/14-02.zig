//! Libpq API example
//! https://gist.github.com/jiacai2050/00709b98ee69d73d022d2f293555f08f
//! https://www.postgresql.org/docs/16/libpq-example.html
//!
const std = @import("std");
const c = @cImport({
    @cInclude("libpq-fe.h");
});

const DB = struct {
    conn: *c.PGconn,

    fn init(conn_info: [:0]const u8) !DB {
        const conn = c.PQconnectdb(conn_info);
        if (c.PQstatus(conn) != c.CONNECTION_OK) {
            std.debug.print("Connect failed, err: {s}\n", .{c.PQerrorMessage(conn)});
            return error.connect;
        }
        return DB{ .conn = conn.? };
    }

    fn deinit(self: DB) void {
        c.PQfinish(self.conn);
    }

    fn exec(self: DB, query: [:0]const u8) !void {
        const result = c.PQexec(self.conn, query);
        defer c.PQclear(result);

        if (c.PQresultStatus(result) != c.PGRES_COMMAND_OK) {
            std.debug.print("exec query failed, query:{s}, err: {s}\n", .{ query, c.PQerrorMessage(self.conn) });
            return error.Exec;
        }
    }

    fn insertTable(self: DB) !void {
        {
            const res = c.PQprepare(self.conn, "insert_cat_colors", "INSERT INTO cat_colors (name) VALUES ($1) returning id ", 1, null);
            defer c.PQclear(res);
            if (c.PQresultStatus(res) != c.PGRES_COMMAND_OK) {
                std.debug.print("prepare insert cat_colors failed, err: {s}\n", .{c.PQerrorMessage(self.conn)});
                return error.prepare;
            }
        }
        {
            const res = c.PQprepare(self.conn, "insert_cats", "INSERT INTO cats (name, color_id) VALUES ($1, $2)", 2, null);
            defer c.PQclear(res);
            if (c.PQresultStatus(res) != c.PGRES_COMMAND_OK) {
                std.debug.print("prepare insert cats failed, err: {s}\n", .{c.PQerrorMessage(self.conn)});
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
        inline for (cat_colors) |row| {
            const color = row.@"0";
            const cat_names = row.@"1";
            _ = cat_names;
            // PGresult *PQexecPrepared(PGconn *conn,
            //              const char *stmtName,
            //              int nParams,
            //              const char * const *paramValues,
            //              const int *paramLengths,
            //              const int *paramFormats,
            //              int resultFormat);
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

            std.debug.print("res:{d}\n", .{c.PQresultStatus(res)});

            if (c.PQresultStatus(res) != c.PGRES_TUPLES_OK) {
                std.debug.print("exec insert cat_colors failed, err: {s}\n", .{c.PQresultErrorMessage(res)});
                return error.InsertCatColors;
            }

            std.debug.print("row:{d}, cols:{d}\n", .{
                c.PQntuples(res),
                c.PQnfields(res),
            });

            const value: [:0]const u8 = std.mem.span(c.PQgetvalue(res, 0, 0));
            const id = try std.fmt.parseInt(i32, value, 10);
            std.debug.print("value is {d}\n", .{id});
        }
    }
};

pub fn main() !void {
    const conn_info = "host=127.0.0.1 dbname=jiacai user=jiacai";

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
    // const result = c.PQexec(conn, "SELECT datname FROM pg_database");
    // defer c.PQclear(result);
    // if (c.PQresultStatus(result) != c.PGRES_COMMAND_OK) {
    //     std.debug.print("select db failed, err: {s}\n", .{c.PQerrorMessage(conn)});
    //     return error.Exec;
    // }
    // var i: c_int = 0;
    // while (i < c.PQntuples(result)) {
    //     const value = c.PQgetvalue(result, i, 0);
    //     std.debug.print("value is {s}\n", .{value});
    //     i += 1;
    // }
}
