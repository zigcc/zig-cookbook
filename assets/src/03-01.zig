const std = @import("std");
const time = std.time;
const Instant = time.Instant;
const Timer = time.Timer;
const print = std.debug.print;

fn expensive_function() void {
    // sleep 500ms
    std.Thread.sleep(time.ns_per_ms * 500);
}

pub fn main() !void {
    // Method 1: Instant
    const start = try Instant.now();
    expensive_function();
    const end = try Instant.now();
    const elapsed1: f64 = @floatFromInt(end.since(start));
    print("Time elapsed is: {d:.3}ms\n", .{
        elapsed1 / time.ns_per_ms,
    });

    // Method 2: Timer
    var timer = try Timer.start();
    expensive_function();
    const elapsed2: f64 = @floatFromInt(timer.read());
    print("Time elapsed is: {d:.3}ms\n", .{
        elapsed2 / time.ns_per_ms,
    });
}
