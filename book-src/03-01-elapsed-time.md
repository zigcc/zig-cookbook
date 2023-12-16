### Measure the elapsed time between two code sections

[`Instant`] represents a timestamp with respect to the currently executing program that ticks during suspend and can be used to record elapsed time.

Calling [`std.time.Instant.since`] returns a u64 representing nanoseconds elapsed.

```zig
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

    print("Time elapsed in expensive_function() is: {d:.3}ms", .{
        elapsed_ns / time.ns_per_ms,
    });
}
```

[`Instant`]: https://ziglang.org/documentation/master/std/#A;std:time.Instant
[`std.time.Instant.since`]: https://ziglang.org/documentation/master/std/#A;std:time.Instant.since
