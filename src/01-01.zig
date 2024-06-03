const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("tests/zig-zen.txt", .{});
    defer file.close();

    // Wrap the file reader in a buffered reader.
    // Since it's usually faster to read a bunch of bytes at once.
    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    const writer = line.writer();
    var line_no: usize = 1;
    var eof = false;
    while (!eof) : (line_no += 1) {
        reader.streamUntilDelimiter(writer, '\n', null) catch |err| switch (err) {
            error.EndOfStream => eof = true, // One last pass before we exit the while loop
            else => return err, // Propagate error
        };
        // Clear the line so we can reuse it.
        defer line.clearRetainingCapacity();

        print("{d}--{s}\n", .{ line_no, line.items });
    }
}
