## http.Server - std

Starting with release 0.12.0, a very simple implementation of `http.Server` has been introduced.

```zig
{{#include ../src/05-03.zig }}
```

Note: The std implementation exhibits extremely poor performance. If you're planning beyond basic experimentation, consider utilizing alternative libraries such as:
- <https://github.com/karlseguin/http.zig>
- <https://github.com/zigzap/zap>
- <https://github.com/mookums/zzz>
