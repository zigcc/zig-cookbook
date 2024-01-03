### Measure the elapsed time between two code sections

[`Instant`] represents a timestamp with respect to the currently executing program that ticks during suspend and can be used to record elapsed time.

Calling [`std.time.Instant.since`] returns a u64 representing nanoseconds elapsed.

This task is common, that there is a [`Timer`] for convenience.

```zig
{{#include ../src/03-01.zig }}
```

[`instant`]: https://ziglang.org/documentation/0.11.0/std/#A;std:time.Instant
[`timer`]: https://ziglang.org/documentation/0.11.0/std/#A;std:time.Timer
[`std.time.instant.since`]: https://ziglang.org/documentation/0.11.0/std/#A;std:time.Instant.since
