const std = @import("std");
const sqlite = @import("sqlite");

pub fn main() !void {
    var db = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .File = "/tmp/zig-cookbook.db" },
        .open_flags = .{
            .write = true,
            .create = true,
        },
        .threading_mode = .MultiThread,
    });
    try createTable(&db);
    try insertTable(&db);
}

fn createTable(db: *sqlite.Db) !void {
    const create_tables = .{
        \\ create table if not exists cat_colors (
        \\   id integer primary key,
        \\   name text not null unique
        \\ );
        ,
        \\ create table if not exists cats (
        \\   id integer primary key,
        \\   name text not null,
        \\   color_id integer not null references cat_colors(id)
        \\ );
    };

    inline for (create_tables) |query| {
        var stmt = try db.prepare(query);
        defer stmt.deinit();

        try stmt.exec(.{}, .{});
    }
}

fn insertTable(db: *sqlite.Db) !void {
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

    const query =
        \\INSERT INTO cat_colors (name) values (?)
    ;
    var stmt = try db.prepare(query);
    defer stmt.deinit();

    // const query2 =
    //     \\INSERT INTO cats (name, color_id) values (?, ?)
    // ;
    // _ = query2;
    // var stmt2 = try db.prepare(query);
    // defer stmt2.deinit();
    inline for (cat_colors) |item| {
        const color = item.@"0";
        const catnames = item.@"1";
        _ = catnames;

        try db.exec("INSERT INTO cat_colors (name) values (?)", .{}, .{color});
        // stmt.reset();
    }
}
