const std = @import("std");
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    var dir = try std.Io.Dir.cwd().openDir(io, "src", .{ .iterate = true });
    defer dir.close(io);

    var walker = try dir.walk(gpa);
    defer walker.deinit();

    const now_ns = std.Io.Clock.real.now(io).nanoseconds;
    while (try walker.next(io)) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.basename, ".smd")) continue;

        const stat = try dir.statFile(io, entry.path, .{});
        const age_ns = now_ns - stat.mtime.nanoseconds;
        if (age_ns < 0) continue;
        if (age_ns < std.time.ns_per_hour * 24) {
            print("modified {d}s ago, size: {d}, file: {s}\n", .{
                @divTrunc(age_ns, std.time.ns_per_s),
                stat.size,
                entry.path,
            });
        }
    }
}
