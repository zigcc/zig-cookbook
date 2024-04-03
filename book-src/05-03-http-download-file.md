## Download

Parses the supplied URL and downloads a file over HTTP using a synchronous GET request
with [`request`]. Creates a target file with a supplied name within the current working directory and copies
the downloaded content into it with `createFile()`. The file is deleted with `deleteFile()` before the program exists

> Note: Since HTTP support is in early stage, it's recommended to use [libcurl](https://curl.se/libcurl/c/) for any complex task.

```zig
{{#include ../src/05-03.zig }}
```

[`request`]: https://ziglang.org/documentation/0.11.0/std/src/std/http/Client.zig.html#L992
[`response`]: https://ziglang.org/documentation/0.11.0/std/src/std/http/Client.zig.html#L322
