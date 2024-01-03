//! Start a TCP server at an unused port.
//!
//! Test with
//! echo "hello zig" | nc localhost <port>

const std = @import("std");
const print = std.debug.print;
const net = std.net;

const select = @import("./select-address.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const myAddr = try select.myAddress();
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
