## http.Server - std

Starting with release 0.12.0, a very simple implementation of `http.Server` has been introduced.

```zig
{{#include ../src/05-03.zig }}
```

> Note: This implementation has very poor performance. If you plan to do more than toy development, consider alternative libraries such as [http.zig](https://github.com/karlseguin/http.zig), [zap](https://github.com/zigzap/zap), [jetzig](https://pismice.github.io/HEIG_ZIG/docs/web/jetzig/), [zzz](https://github.com/mookums/zzz) (note that it is not yet mature), etc.
