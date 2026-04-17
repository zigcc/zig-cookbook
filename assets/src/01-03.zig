//! Find files that have been modified in the last 24 hours

const std = @import("std");
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    var iter_dir = try std.Io.Dir.cwd().openDir(io, "src", .{ .iterate = true });
    defer iter_dir.close(io);

    var walker = try iter_dir.walk(gpa);
    defer walker.deinit();

    const now_ns = std.Io.Clock.real.now(io).nanoseconds;
    while (try walker.next(io)) |entry| {
        if (entry.kind != .file) {
            continue;
        }

        const stat = try iter_dir.statFile(io, entry.path, .{});
        const last_modified = stat.mtime.nanoseconds;
        const duration = now_ns - last_modified;
        if (duration < std.time.ns_per_hour * 24) {
            print("Last modified: {d} seconds ago, size:{d} bytes, filename: {s}\n", .{
                @divTrunc(duration, std.time.ns_per_s),
                stat.size,
                entry.path,
            });
        }
    }
}
