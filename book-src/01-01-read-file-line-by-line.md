# Read file line by line

There is a [`Reader`] type in Zig, which provides various methods to read file, such as `readAll`, `readInt`. Here we will use `streamUntilDelimiter` to split lines.

```zig
{{#include ../src/01-01.zig }}
```

[`reader`]: https://ziglang.org/documentation/0.11.0/std/#A;std:io.Reader
