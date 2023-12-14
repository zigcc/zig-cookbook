//! File names that have been modified in the last 24 hours

const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var iter_dir = try fs.cwd().openIterableDir(".", .{
        .no_follow = true, // `true` means it won't dereference the symlinks.
    });
    defer iter_dir.close();

    var walker = try iter_dir.walk(allocator);
    defer walker.deinit();

    const now = std.time.nanoTimestamp();
    while (try walker.next()) |entry| {
        if (entry.kind != .file) {
            continue;
        }

        const file = try iter_dir.dir.openFile(entry.path, .{});
        const md = try file.metadata();
        const last_modified = md.modified();
        const duration = now - last_modified;
        if (duration < std.time.ns_per_hour * 24) {
            print("Last modified: {d} seconds ago, read_only:{any}, size:{d} bytes, filename: {s}\n", .{
                @divTrunc(duration, std.time.ns_per_s),
                md.permissions().readOnly(),
                md.size(),
                entry.path,
            });
        }
    }
}
