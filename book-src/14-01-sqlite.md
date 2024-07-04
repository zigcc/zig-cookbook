# SQLite

Although there are some [wrapper package](https://github.com/vrischmann/zig-sqlite) options for SQLite in Zig, they are unstable. So here we will introduce the [C API interface](https://www.sqlite.org/cintro.html).

Data models are introduced [here](database.md).

```zig
{{#include ../src/14-01.zig }}
```
