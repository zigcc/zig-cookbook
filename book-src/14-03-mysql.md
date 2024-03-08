# MySQL


As with [previous section](./14-01-sqlite.md), here we introduce [libpq](https://www.postgresql.org/docs/16/libpq-example.html) interface directly, other than [wrapper package](https://github.com/tonis2/zig-postgres).

Data models used in demo are the same with the one used in [SQLite section](./14-01-sqlite.md).

> Note: After execute a query with `PQexec` like functions, if there are returning results, check the result with `PGRES_TUPLES_OK`, otherwise `PGRES_COMMAND_OK` should be used.

- <https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESULTSTATUS>


As with [sqlite section](./14-01-sqlite.md), here we introduce [libmysql_client](https://dev.mysql.com/doc/c-api/8.0/en/c-api-basic-interface-usage.html) interface directly.

Data models used in demo are the same with the one used in [SQLite section](./14-01-sqlite.md).

> Note: After execute a query with `mysql_real_query` like functions, if there are returning results, we must consume the result, Otherwise we will get following error when we execute next query.

```
Commands out of sync; you can't run this command now
```

- <https://dev.mysql.com/doc/c-api/8.0/en/mysql-next-result.html>

```zig
{{#include ../src/14-03.zig }}
```
