const std = @import("std");
const net = std.net;
const print = std.debug.print;

pub fn main() !void {
    const loopback = try net.Ip4Address.parse("127.0.0.1", 0);
    const localhost = net.Address{ .in = loopback };
    var server = net.StreamServer.init(net.StreamServer.Options{
        .reuse_port = true,
    });
    defer server.deinit();

    try server.listen(localhost);

    const addr = server.listen_address;
    print("Listening on {}, access this port to end the program\n", .{addr.getPort()});

    var client = try server.accept();
    defer client.stream.close();

    print("Connection received! {} is sending data.\n", .{client.address});

    var buf: [16]u8 = undefined;
    const n = try client.stream.reader().read(&buf);
    print("{} says {s}\n", .{ client.address, buf[0..n] });
}
