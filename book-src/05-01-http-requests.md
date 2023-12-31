## GET

Parses the supplied URL and makes a synchronous HTTP GET request
with [`request`]. Prints obtained [`Response`] status and headers.

> Note: Since HTTP support is in early stage, it's recommended to use [libcurl](https://curl.se/libcurl/c/) for any complex task.

```zig
const std = @import("std");
const print = std.debug.print;
const http = std.http;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var headers = http.Headers{ .allocator = allocator };
    defer headers.deinit();

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    const uri = try std.Uri.parse("http://httpbin.org/headers");
    var req = try client.request(.GET, uri, headers, .{});
    defer req.deinit();

    try req.start();
    try req.wait();

    var buf: [1024]u8 = undefined;
    const n = try req.read(&buf);
    const res = req.response;

    print("Status: {}\n", .{res.status});
    print("Headers:\n{}\n", .{res.headers});
    print("Body:\n{s}\n", .{buf[0..n]});
}
```

[`request`]: https://ziglang.org/documentation/0.11.0/std/src/std/http/Client.zig.html#L992
[`Response`]: https://ziglang.org/documentation/0.11.0/std/src/std/http/Client.zig.html#L322
