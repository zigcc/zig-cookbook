## Spawn a short-lived thread

The example uses [`std.Thread`] for concurrent and parallel programming.
[`std.Thread.spawn`] spawns a new thread to calculate the result.

This example splits the array in half and performs the work in separate threads.

> Note: In order to ensure `t1` thread is completed when spawn `t2` fails, we `defer t1.join()` immediately after spawn `t1`.

```zig
{{#include ../src/07-01.zig }}
```

[`std.thread`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread
[`std.thread.spawn`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread.spawn
