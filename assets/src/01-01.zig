const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    const file = try fs.cwd().openFile("tests/zig-zen.txt", .{});
    defer file.close();

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(&file_buffer);
    var line_no: usize = 0;
    while (reader.interface.takeDelimiterExclusive('\n')) |line| {
        line_no += 1;
        print("{d}--{s}\n", .{ line_no, line });
    } else |err| switch (err) {
        error.EndOfStream => {}, // Normal termination
        else => return err, // Propagate error
    }

    print("Total lines: {d}\n", .{line_no});
}
