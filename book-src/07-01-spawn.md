## Spawn a short-lived thread

The example uses [`std.Thread`] for concurrent and parallel programming.
[`std.Thread.spawn`] spawns a new thread to calculate the result.

This example splits the array in half and performs the work in separate threads.

```zig
{{#include ../src/07-01.zig }}
```

Output Log:

```
findMax function max value is 25, array list is { 1, 25 }
findMax function max value is 10, array list is { -4, 10 }
findMax function max value is 200, array list is { 100, 200 }
findMax function max value is -100, array list is { -100, -200 }
```

[`std.thread`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread
[`std.thread.spawn`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread.spawn
