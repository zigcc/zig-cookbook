//! Find files that have been modified in the last 24 hours

const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;
const print = std.debug.print;

const current_zig = builtin.zig_version;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var iter_dir = if (comptime current_zig.minor == 11)
        try fs.cwd().openIterableDir(".", .{
            .no_follow = true, // `true` means it won't dereference the symlinks.
        })
    else
        fs.cwd().openDir(".", .{ .iterate = true });
    defer iter_dir.close();

    var walker = try iter_dir.walk(allocator);
    defer walker.deinit();

    const now = std.time.nanoTimestamp();
    while (try walker.next()) |entry| {
        if (entry.kind != .file) {
            continue;
        }

        const stat = try iter_dir.dir.statFile(entry.path);
        const last_modified = stat.mtime;
        const duration = now - last_modified;
        if (duration < std.time.ns_per_hour * 24) {
            print("Last modified: {d} seconds ago, size:{d} bytes, filename: {s}\n", .{
                @divTrunc(duration, std.time.ns_per_s),
                stat.size,
                entry.path,
            });
        }
    }
}
