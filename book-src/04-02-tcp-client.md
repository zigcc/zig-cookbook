## TCP Client

In this example, we demonstrate creation of a TCP client to connect to the server from the previous section.
You can run it using `zig build run-04-02 -- <port>`.

```zig
{{#include ../src/04-02.zig }}
```

By default, the program connects with IPv4. If you want IPv6, use
`::1` instead of `127.0.0.1`, replace `net.Address.parseIp4` by
`net.Address.parseIp6`.
