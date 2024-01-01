const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("tests/zig-zen.txt", .{});
    defer file.close();

    // Wrap the files reader in a buffered reader.
    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();
    const writer = line.writer();

    var line_no: usize = 1;
    while (reader.streamUntilDelimiter(writer, '\n', null)) : (line_no += 1) {
        print("{d}--{s}\n", .{ line_no, line.items });

        // Clear the line so we can reuse it.
        line.clearRetainingCapacity();
    } else |err| switch (err) {
        error.EndOfStream => {}, // Continue on
        else => |e| return e, // Propagate error
    }
}
