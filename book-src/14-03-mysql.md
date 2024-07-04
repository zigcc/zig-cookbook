# MySQL

As with [sqlite section](./14-01-sqlite.md), here we introduce [libmysqlclient](https://dev.mysql.com/doc/c-api/8.0/en/c-api-basic-interface-usage.html) interface directly.

Data models are introduced [here](database.md).

> Note: After executing a query with `mysql_real_query` like functions, if there are returning results, we must consume the result, otherwise we will get following error when we execute next query.

```
Commands out of sync; you can't run this command now
```

- <https://dev.mysql.com/doc/c-api/8.0/en/mysql-next-result.html>

```zig
{{#include ../src/14-03.zig }}
```
