const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // In order to walk the directry, `iterate` must be set to true.
    var dir = try fs.cwd().openDir(".", .{ .iterate = true });
    defer dir.close();

    var walker = try dir.walk(allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        print("path: {s}, basename:{s}, type:{s}\n", .{
            entry.path,
            entry.basename,
            @tagName(entry.kind),
        });
    }
}
