## Run Once

`std.once` ensures a function executes exactly one time, regardless of how many threads attempt to call it or how many times it's invoked. This thread-safe initialization is particularly useful for singleton patterns and one-time setup operations.

```Zig
{{#include ../src/07-04.zig}}
```
