//! Start a UDP echo on an unused port.
//!
//! Test with
//! echo "hello zig" | nc -u localhost <port>

const std = @import("std");
const net = std.net;
const posix = std.posix;
const print = std.debug.print;

pub fn main() !void {
    // adjust the ip/port here as needed
    const addr = try net.Address.parseIp("127.0.0.1", 32100);

    // get a socket and set domain, type and protocol flags
    const sock = try posix.socket(
        posix.AF.INET,
        posix.SOCK.DGRAM,
        posix.IPPROTO.UDP,
    );

    // for completeness, we defer closing the socket. In practice, if this is
    // a one-shot program, we could omit this and let the OS do the cleanup
    defer posix.close(sock);

    try posix.bind(sock, &addr.any, addr.getOsSockLen());

    var other_addr: posix.sockaddr = undefined;
    var other_addrlen: posix.socklen_t = @sizeOf(posix.sockaddr);

    var buf: [1024]u8 = undefined;

    print("Listen on {f}\n", .{addr});

    // we did not set the NONBLOCK flag (socket type flag),
    // so the program will wait until data is received
    const n_recv = try posix.recvfrom(
        sock,
        buf[0..],
        0,
        &other_addr,
        &other_addrlen,
    );
    print(
        "received {d} byte(s) from {any};\n    string: {s}\n",
        .{ n_recv, other_addr, buf[0..n_recv] },
    );

    // we could extract the source address of the received data by
    // parsing the other_addr.data field

    const n_sent = try posix.sendto(
        sock,
        buf[0..n_recv],
        0,
        &other_addr,
        other_addrlen,
    );
    print("echoed {d} byte(s) back\n", .{n_sent});
}
