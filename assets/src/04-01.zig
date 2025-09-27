//! Start a TCP server at an unused port.
//!
//! Test with
//! echo "hello zig" | nc localhost <port>

const std = @import("std");
const net = std.net;
const print = std.debug.print;

pub fn main() !void {
    const loopback = try net.Ip4Address.parse("127.0.0.1", 0);
    const localhost = net.Address{ .in = loopback };
    var server = try localhost.listen(.{
        .reuse_address = true,
    });
    defer server.deinit();

    const addr = server.listen_address;
    print("Listening on {}, access this port to end the program\n", .{addr.getPort()});

    var client = try server.accept();
    defer client.stream.close();

    print("Connection received! {f} is sending data.\n", .{client.address});

    var buf: [1024]u8 = undefined;
    const size = try client.stream.read(&buf);
    print("{f} says {s}\n", .{ client.address, buf[0..size] });
}
