# Database

This section will demonstrate how to connect to popular databases from Zig.

Data model used are as follows:

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
