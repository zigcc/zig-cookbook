const std = @import("std");
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const file = try std.Io.Dir.cwd().openFile(io, "tests/zig-zen.txt", .{});
    defer file.close(io);

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(io, &file_buffer);
    var line_no: usize = 0;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        line_no += 1;
        print("{d}--{s}\n", .{ line_no, line });
    }

    try std.testing.expectEqual(13, line_no);
    print("Total lines: {d}\n", .{line_no});
}
