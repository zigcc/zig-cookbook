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

The next section will show how to connect this server using Zig code.
