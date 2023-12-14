const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    // allocate a large enough buffer to store the cwd
    var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;

    const home = std.fs.cwd();
    const fs_home = try home.realpath(".", &buf);
    print("Entries modified in the last 24 hours in {s}:\n", .{fs_home});

    const now = std.time.nanoTimestamp();
    const before_24h = now - std.time.ns_per_day;

    var dir = try std.fs.cwd().openIterableDir(".", .{});
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;

        const stat = try home.statFile(entry.name);
        if (stat.mtime < before_24h) continue;

        print("Last modified: {} seconds, size: {} bytes, filename: {s}\n", .{
            @divTrunc(now - stat.mtime, std.time.ns_per_s),
            stat.size,
            entry.name,
        });
    }
}
