# Postgres

As with [previous section](./14-01-sqlite.md), here we introduce [libpq](https://www.postgresql.org/docs/16/libpq-example.html) interface directly, other than [wrapper package](https://github.com/tonis2/zig-postgres).

Data models used in demo are the same with the one used in [SQLite section](./14-01-sqlite.md).

> Note: After execute a query with `PQexec` like functions, if there are returning results, check the result with `PGRES_TUPLES_OK`, otherwise `PGRES_COMMAND_OK` should be used.

- <https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESULTSTATUS>

```zig
{{#include ../src/14-02.zig }}
```
