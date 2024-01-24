## Pass Data between two threads

The example uses [`std.Thread`] for concurrent and parallel programming.
[`std.Thread.spawn`] spawns a new thread to calculate the result.

This example splits the array in half and performs the work in separate threads.

### Multithreading with Shared Memory

```zig
{{#include ../src/07-02.zig}}
```

**Note*: Because [`event.Channel`] is still being updated and the required `async` feature has not yet been added, so we can't directly use `Channel` to pass data from multiple threads.

[`std.thread`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread
[`std.thread.spawn`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread.spawn