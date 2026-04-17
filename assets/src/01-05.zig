const std = @import("std");
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    // In order to walk the directry, `iterate` must be set to true.
    var dir = try std.Io.Dir.cwd().openDir(io, "zig-out", .{ .iterate = true });
    defer dir.close(io);

    var walker = try dir.walk(gpa);
    defer walker.deinit();

    while (try walker.next(io)) |entry| {
        print("path: {s}, basename:{s}, type:{s}\n", .{
            entry.path,
            entry.basename,
            @tagName(entry.kind),
        });
    }
}
