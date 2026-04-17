//! Start a UDP echo on an unused port.
//!
//! Test with
//! echo "hello zig" | nc -u localhost <port>

const std = @import("std");
const net = std.Io.net;
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // adjust the ip/port here as needed
    const addr = try net.IpAddress.parse("127.0.0.1", 32100);

    // Bind a UDP socket
    const sock = try addr.bind(io, .{ .mode = .dgram, .protocol = .udp });
    defer sock.close(io);

    var buf: [1024]u8 = undefined;

    print("Listen on {f}\n", .{addr});

    // we did not set the NONBLOCK flag, so the program will wait until data is received
    const msg = try sock.receive(io, &buf);
    print(
        "received {d} byte(s) from {f};\n    string: {s}\n",
        .{ msg.data.len, msg.from, msg.data },
    );

    try sock.send(io, &msg.from, msg.data);
    print("echoed {d} byte(s) back\n", .{msg.data.len});
}
