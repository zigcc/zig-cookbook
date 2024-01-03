## Listen on unused port TCP/IP

In this example, the port is displayed on the console, and the program
will listen until a request is made. `Ip4Address` (used in the
imported `select-address.zig`) assigns a random port when setting port
to 0. By default, the program listens with IPv4, edit
`select-address.zig` if you want IPv6.

```zig
{{#include ../src/select-address.zig }}

{{#include ../src/04-01.zig }}
```

When start starts up, try test like this:

```bash
echo "hello zig" | nc localhost <port>
```

(Or may be somehting like `ip6-localhost` if you use IPv6, depending
on the way your machine is set up.)

The next section will show how to connect this server using Zig code.
