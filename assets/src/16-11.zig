//! Synchronize a file through std.Io.File.MemoryMap.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const path = "zig-cookbook-io-map.txt";
    defer std.Io.Dir.cwd().deleteFile(io, path) catch {};

    {
        var file = try std.Io.Dir.cwd().createFile(io, path, .{});
        defer file.close(io);
        try file.writeStreamingAll(io, "mapped");
    }

    var file = try std.Io.Dir.cwd().openFile(io, path, .{ .mode = .read_write });
    defer file.close(io);

    var mapping = try file.createMemoryMap(io, .{
        .len = "mapped".len,
        .protection = .{ .read = true, .write = true },
    });
    defer mapping.destroy(io);

    try mapping.read(io);
    mapping.memory[0] = 'M';
    try mapping.write(io);
    std.debug.print("mapped first byte: {c}\n", .{mapping.memory[0]});
}
