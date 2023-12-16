const std = @import("std");
const time = std.time;
const Instant = time.Instant;
const print = std.debug.print;

fn expensive_function() void {
    // sleep 500ms
    time.sleep(time.ns_per_ms * 500);
}

pub fn main() !void {
    const start = try Instant.now();
    expensive_function();
    const now = try Instant.now();
    const elapsed_ns: f64 = @floatFromInt(now.since(start));

    print("Time elapsed in expensive_function() is: {d:.3}ms\n", .{
        elapsed_ns / time.ns_per_ms,
    });
}
