//! Write a temporary file and atomically replace the destination.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const destination = "zig-cookbook-atomic.txt";
    var atomic = try std.Io.Dir.cwd().createFileAtomic(io, destination, .{ .replace = true });
    defer atomic.deinit(io);
    var buffer: [1024]u8 = undefined;
    var writer = atomic.file.writer(io, &buffer);
    try writer.interface.writeAll("all bytes are written before commit\n");
    try writer.interface.flush();
    try atomic.replace(io);
    defer std.Io.Dir.cwd().deleteFile(io, destination) catch {};
    std.debug.print("atomically replaced {s}\n", .{destination});
}
