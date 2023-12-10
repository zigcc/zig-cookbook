const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file = try fs.cwd().openFile("build.zig", .{});
    defer file.close();

    const rdr = file.reader();
    var line_no: usize = 0;
    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        line_no += 1;
        print("{d}--{s}\n", .{ line_no, line });
    }
}
