const std = @import("std");
const time = std.time;
const Instant = time.Instant;
const print = std.debug.print;

fn expensive_function() void {
    time.sleep(time.ns_per_s);
}

pub fn main() !void {
    const start = try Instant.now();
    expensive_function();
    const now = try Instant.now();
    const duration = now.since(start);
    const duration_s = @as(f64, @floatFromInt(duration));

    print("Time elapsed in expensive_function() is: {d:.3}s", .{duration_s / time.ns_per_s});
}
