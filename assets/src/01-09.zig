//! Create a TAR archive with the standard library.
//!
//! TAR is an archive format rather than a compressor; compress the resulting
//! file with gzip/zstd when a compressed tarball is needed. The standard
//! library provides ZIP parsing/extraction, but no portable ZIP writer API.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const archive = try std.Io.Dir.cwd().createFile(io, "zig-cookbook.tar", .{ .truncate = true });
    defer {
        archive.close(io);
        std.Io.Dir.cwd().deleteFile(io, "zig-cookbook.tar") catch {};
    }

    var buffer: [4096]u8 = undefined;
    var writer = archive.writer(io, &buffer);
    var tar_writer: std.tar.Writer = .{ .underlying_writer = &writer.interface };
    try tar_writer.writeFileBytes("message.txt", "hello from a tar archive\n", .{});
    try tar_writer.finishPedantically();
    try writer.interface.flush();
    std.debug.print("created a portable TAR archive containing message.txt\n", .{});
}
