//! Show the I/O context provided by std.process.Init.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const stdout = std.Io.File.stdout();

    try stdout.writeStreamingAll(io, "std.Io is passed through the process context.\n");

    var args = init.minimal.args.iterate();
    var argument_count: u32 = 0;
    while (args.next()) |_| {
        argument_count += 1;
    }

    var writer_buffer: [256]u8 = undefined;
    var writer = stdout.writer(io, &writer_buffer);
    try writer.interface.print("arguments: {d}\n", .{argument_count});
    try writer.interface.print("environment entries: {d}\n", .{init.environ_map.count()});
    try writer.interface.flush();
}
