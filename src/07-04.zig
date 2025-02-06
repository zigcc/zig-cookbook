const std = @import("std");
const builtin = @import("builtin");

var n: u8 = 0;

fn incr() void {
    n = n + 1;
}

var once_incr = std.once(incr);
fn onceIncr() void {
    once_incr.call();
    once_incr.call();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const allocator = gpa.allocator();

    var poll: std.Thread.Pool = undefined;
    try poll.init(.{ .allocator = allocator });
    defer poll.deinit();

    var wg = std.Thread.WaitGroup{};
    for (0..8) |_|
        poll.spawnWg(&wg, onceIncr, .{});
    wg.wait();

    try std.testing.expectEqual(1, n);
}
