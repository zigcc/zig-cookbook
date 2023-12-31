const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("tests/zig-zen.txt", .{});
    defer file.close();

    const rdr = file.reader();
    var line_no: usize = 0;
    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        defer allocator.free(line);

        line_no += 1;
        print("{d}--{s}\n", .{ line_no, line });
    }
}
