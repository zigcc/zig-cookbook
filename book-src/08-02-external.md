# External Command

Run external command via [`std.process.Child`], and collect output into `ArrayList` via [pipe].

```zig
{{#include ../src/08-02.zig }}
```

[`std.process.child`]: https://ziglang.org/documentation/0.11.0/std/#A;std:process.Child
[pipe]: https://man7.org/linux/man-pages/man2/pipe.2.html
