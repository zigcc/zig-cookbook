//! Use std.Io.Dir and std.Io.File handles for a complete file round trip.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const path = "zig-cookbook-io-demo.txt";
    defer std.Io.Dir.cwd().deleteFile(io, path) catch {};

    {
        var file = try std.Io.Dir.cwd().createFile(io, path, .{});
        defer file.close(io);
        try file.writeStreamingAll(io, "written through an Io.File handle\n");
    }

    var reader_buffer: [128]u8 = undefined;
    var reader = (try std.Io.Dir.cwd().openFile(io, path, .{})).reader(io, &reader_buffer);
    defer reader.file.close(io);

    const contents = try reader.interface.allocRemaining(init.gpa, .limited(reader_buffer.len));
    defer init.gpa.free(contents);
    std.debug.print("{s}", .{contents});
}
