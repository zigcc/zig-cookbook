## TCP Client

In this example, we demonstrate how to create a TCP client to connect to the server from the previous section.
You can run it using `zig build run 04-02 -- <port>`.

```zig
const std = @import("std");
const net = std.net;
const print = std.debug.print;

pub fn main() !void {
    var args = std.process.args();
    // The First (0 index) Argument is the path to the program.
    _ = args.skip();
    const port_value = args.next() orelse {
        print("expect port as command line argument\n", .{});
        std.os.exit(1);
    };
    const port = try std.fmt.parseInt(u16, port_value, 10);

    const peer = try net.Address.parseIp4("127.0.0.1", port);
    // Connect to peer
    const stream = try net.tcpConnectToAddress(peer);
    defer stream.close();
    print("Connecting to {}\n", .{peer});

    // Sending data to peer
    const data = "hello zig";
    var writer = stream.writer();
    const size = try writer.write(data);
    print("Sending '{s}' to peer, total written: {d} bytes\n", .{ data, size });
    // Or just using `stream.writeAll`
    // try stream.writeAll("hello zig");
}
```
