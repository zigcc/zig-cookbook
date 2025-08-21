const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("Number of logical cores is {}\n", .{try std.Thread.getCpuCount()});
}
