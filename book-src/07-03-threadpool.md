## Thread pool

Thread pools address two different problems:
1. They usually provide improved performance when executing large numbers of asynchronous tasks, due to reduced per-task invocation overhead, and
2. They provide a means of bounding and managing the resources, including threads, consumed when executing a collection of tasks.


In this example, we spawn 10 tasks into thread pool, and use `WaitGroup` to wait for them to finish.

```zig
{{#include ../src/07-03.zig}}
```
