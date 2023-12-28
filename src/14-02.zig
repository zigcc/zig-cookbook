//! Libpq API example
//! https://gist.github.com/jiacai2050/00709b98ee69d73d022d2f293555f08f
//! https://www.postgresql.org/docs/16/libpq-example.html
//!
const std = @import("std");
const c = @cImport({
    @cInclude("libpq-fe.h");
});

pub fn main() !void {
    const conn_info = "host=127.0.0.1 dbname=jiacai user=jiacai";

    const conn = c.PQconnectdb(conn_info);
    std.debug.print("{any}\n", .{@TypeOf(conn)});

    defer c.PQfinish(conn);
    if (c.PQstatus(conn) != c.CONNECTION_OK) {
        std.debug.print("Connect failed, err: {s}\n", .{c.PQerrorMessage(conn)});
        return error.connect;
    }

    const result = c.PQexec(conn, "SELECT datname FROM pg_database");
    defer c.PQclear(result);
    if (c.PQresultStatus(result) != c.PGRES_COMMAND_OK) {
        std.debug.print("select db failed, err: {s}\n", .{c.PQerrorMessage(conn)});
        return error.Exec;
    }
    var i: c_int = 0;
    while (i < c.PQntuples(result)) {
        const value = c.PQgetvalue(result, i, 0);
        std.debug.print("value is {s}\n", .{value});
        i += 1;
    }
}
