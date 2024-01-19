## Pass Data between two threads

The example uses [`std.Thread`] for concurrent and parallel programming.
[`std.Thread.spawn`] spawns a new thread to calculate the result.

This example splits the array in half and performs the work in separate threads.

### Multithreading with Shared Memory

```zig
{{#include ../src/07-02.zig}}
```

Output Log:

```
Thread 15201517 locked mutex, current value is: 0
Thread 15201517 updated value to 1000
Thread 15201518 locked mutex, current value is: 0
Thread 15201518 updated value to 4000
Final value: 4000
```

Test Log:
```
Test [1/1] test.test threadFunc updates shared data correctly... Thread 15211999 locked mutex, current value is: 0
Thread 15211999 updated value to 50
All 1 tests passed.
```

### Condition and Mutex

```zig
{{#include ../src/07-02-02.zig}}
```

### Semaphore

```zig
{{#include ../src/07-02-03.zig}}
```

### Wait Group

```zig
{{#include ../src/07-02-04.zig}}
```

### Channel

```zig
{{#include ../src/07-02-05.zig}}
```
**Note*: Because [`event.Channel`] is still being updated and the required `async` feature has not yet been added, I wrote a simulated channel to implement this functionality.

[`std.thread`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread
[`std.thread.spawn`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread.spawn
[`event.Channel`]: https://ziglang.org/documentation/0.11.0/std/#A;std:event.Channel
