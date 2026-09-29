//! Read a large file with the low-level streaming file API.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const source = try std.Io.Dir.cwd().openFile(io, "build.zig", .{});
    defer source.close(io);
    const destination = try std.Io.Dir.cwd().createFile(io, "zig-cookbook-buffered-copy.txt", .{ .truncate = true });
    defer {
        destination.close(io);
        std.Io.Dir.cwd().deleteFile(io, "zig-cookbook-buffered-copy.txt") catch {};
    }

    var buffer: [8192]u8 = undefined;
    var bytes_copied: usize = 0;
    while (true) {
        const bytes_read = source.readStreaming(io, &.{buffer[0..]}) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        if (bytes_read == 0) break;
        try destination.writeStreamingAll(io, buffer[0..bytes_read]);
        bytes_copied += bytes_read;
    }
    std.debug.print("copied {d} bytes with direct file I/O\n", .{bytes_copied});
}
