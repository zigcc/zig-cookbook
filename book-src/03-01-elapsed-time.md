### Measure the elapsed time between two code sections

[`Instant`] represents a timestamp with respect to the currently executing program that ticks during suspend and can be used to record elapsed time.

Calling [`std.time.Instant.since`] returns a u64 representing nanoseconds elapsed.

This task is common, that there is a [`Timer`] for convenience.
```zig
const std = @import("std");
const time = std.time;
const Instant = time.Instant;
const Timer = time.Timer;
const print = std.debug.print;

fn expensive_function() void {
    // sleep 500ms
    time.sleep(time.ns_per_ms * 500);
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
    const elapsed2 f64 = @floatFromInt(timer.read());
    print("Time elapsed is: {d:.3}ms\n", .{
        elapsed2 / time.ns_per_ms,
    });
}

```

[`Instant`]: https://ziglang.org/documentation/0.11.0/std/#A;std:time.Instant
[`Timer`]: https://ziglang.org/documentation/0.11.0/std/#A;std:time.Timer
[`std.time.Instant.since`]: https://ziglang.org/documentation/0.11.0/std/#A;std:time.Instant.since
