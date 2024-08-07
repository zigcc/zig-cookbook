## Listen on unused port TCP/IP

In this example, the port is displayed on the console, and the program will
listen until a request is made. `Ip4Address` assigns a random port when
setting port to 0.

```zig
{{#include ../src/04-01.zig }}
```

When start starts up, try test like this:

```bash
echo "hello zig" | nc localhost <port>
```

By default, the program listens with IPv4. If you want IPv6, use `::1`
instead of `127.0.0.1`, replace `net.Ip4Address.parse` by
`net.Ip6Address.parse` and the field `.in` in the creation of the
`net.Address` with `.in6`.

(And connect to something like `ip6-localhost`, depending on the way
your machine is set up.)

The next section will show how to connect to this server using Zig code.
