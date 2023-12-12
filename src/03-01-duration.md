## Measure the elapsed time between two code sections

Measures [`std.time.Instant.since`] since [`std.time.Instant.now`].

Calling [`std.time.Instant.since`] returns some nanoseconds that we print at the end of the example.

```zig,0.11.0
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
```

[`std.time.ns_per_s`]: https://ziglang.org/documentation/master/std/#A;std:time.ns_per_s
[`std.time.Instant.since`]: https://ziglang.org/documentation/master/std/#A;std:time.Instant.since
[`std.time.Instant.now`]: https://ziglang.org/documentation/master/std/#A;std:time.Instant.now
[`std.time.Instant`]:https://ziglang.org/documentation/master/std/#A;std:time.Instant
