# Check file existence

In this example, `access` is utilized to verify file existence; however, for it to function correctly, one must specifically check for the `FileNotFound` error type.

```zig
{{#include ../src/01-04.zig}}
```

However, there is a gotcha described in [its documentation](https://github.com/ziglang/zig/blob/0.13.0/lib/std/fs/Dir.zig#L2390-L2396):

> Be careful of [Time-Of-Check-Time-Of-Use](https://en.wikipedia.org/wiki/Time-of-check_to_time-of-use) race conditions when using this function.
> For example, instead of testing if a file exists and then opening it, just open it and handle the error for file not found.
