# SQLite

Although there are some [wrapper package](https://github.com/vrischmann/zig-sqlite) for SQLite in Zig, they are unstable. So here we will introduce the [C API interface](https://www.sqlite.org/cintro.html).

The demo below will

1. Create two tables: `cat_colors`, `cats`, `cats` has a reference in `cat_colors`.
2. Create prepare statement for each table, and insert data.
3. Execute a join query to get `cat_name` and `color_name` at the same time.

## cat_colors

| id  | name  |
| --- | ----- |
| 1   | Blue  |
| 2   | Black |

## cats

| id  | name    | color_id |
| --- | ------- | -------- |
| 1   | Tigger  | 1        |
| 2   | Sammy   | 1        |
| 3   | Oreo    | 2        |
| 4   | Biscuit | 2        |

```zig
{{#include ../src/14-01.zig }}
```
