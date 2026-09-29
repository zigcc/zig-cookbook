//! Wait for a UDP datagram with a bounded receive time.

const std = @import("std");
const net = std.Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const address = net.IpAddress{ .ip4 = .loopback(0) };
    const socket = try address.bind(io, .{
        .mode = .dgram,
        .protocol = .udp,
    });
    defer socket.close(io);

    var buffer: [1024]u8 = undefined;
    const timeout: std.Io.Timeout = .{
        .duration = .{
            .clock = .awake,
            .raw = .fromNanoseconds(250 * std.time.ns_per_ms),
        },
    };
    _ = socket.receiveTimeout(io, &buffer, timeout) catch |err| switch (err) {
        error.Timeout => {
            std.debug.print("no datagram received within 250 ms\n", .{});
            return;
        },
        else => return err,
    };
}
