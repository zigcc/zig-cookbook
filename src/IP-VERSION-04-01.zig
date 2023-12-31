//! Start a TCP server at an unused port.
//!
//! Test with
//! echo "hello zig" | nc localhost <port>

const std = @import("std");
const net = std.net;
const print = std.debug.print;

const ipVersion = 6; // Currently (december 2023), only 4 or 6

inline fn myAddress() !struct { textAddr: []const u8, local: net.Address } {
    if (ipVersion == 6) {
        const loopback = try net.Ip6Address.parse("::1", 0);
        const localhost = net.Address{ .in6 = loopback };
        return .{.textAddr = "[::1]", .local = localhost};
    } else if (ipVersion == 4) {
        const loopback = try net.Ip4Address.parse("127.0.0.1", 0);
        const localhost = net.Address{ .in = loopback };
        return .{.textAddr = "127.0.0.1", .local = localhost};
    } else unreachable;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const myAddr = try myAddress();
    const textAddress: []const u8 = myAddr.textAddr;
    var server = net.StreamServer.init(net.StreamServer.Options{
        .reuse_port = true,
    });
    defer server.deinit();

    try server.listen(myAddr.local);

    const addr = server.listen_address;
    print("Listening on {s}:{d}, access this port to end the program\n", .{textAddress, addr.getPort()});

    var client = try server.accept();
    defer client.stream.close();

    print("Connection received! {} is sending data.\n", .{client.address});

    const message = try client.stream.reader().readAllAlloc(allocator, 1024);
    defer allocator.free(message);

    print("{} says {s}\n", .{ client.address, message });
}
