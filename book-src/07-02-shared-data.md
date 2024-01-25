## Share data between two threads

When we want to mutate data shared in different threads, [`Mutex`](**Mut**ually **ex**clusive flag) must be used to synchronize threads, otherwise you will get unexpected result.

```zig
{{#include ../src/07-02.zig}}
```
If we remove Mutex protection, the result will most like be less than 300.

[`Mutex`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread.Mutex
