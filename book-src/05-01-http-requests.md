## GET

Parses the supplied URL and makes a synchronous HTTP GET request
with [`request`]. Prints obtained [`Response`] status and headers.

> Note: Since HTTP support is in early stage, it's recommended to use [libcurl](https://curl.se/libcurl/c/) for any complex task.

```zig
{{#include ../src/05-01.zig }}
```

[`request`]: https://ziglang.org/documentation/0.11.0/std/src/std/http/Client.zig.html#L992
[`response`]: https://ziglang.org/documentation/0.11.0/std/src/std/http/Client.zig.html#L322
