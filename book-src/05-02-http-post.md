## POST

Parses the supplied URL and makes a synchronous HTTP POST request
with [`request`]. Prints obtained [`Response`] status, and data received from server.

> Note: Since HTTP support is in early stage, it's recommended to use [libcurl](https://curl.se/libcurl/c/) for any complex task.

```zig
{{#include ../src/05-02.zig }}
```

[`request`]: https://ziglang.org/documentation/0.11.0/std/src/std/http/Client.zig.html#L992
[`response`]: https://ziglang.org/documentation/0.11.0/std/src/std/http/Client.zig.html#L322
