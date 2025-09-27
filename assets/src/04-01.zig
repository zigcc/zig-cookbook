//! Start an echo TCP server at an unused port.
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

    const client = try server.accept();
    // In real world, you'd want to handle multiple clients, probably in separate threads.
    try handleClient(client);
}

fn handleClient(client: net.Server.Connection) !void {
    print("Accepted connection from {f}\n", .{client.address});
    defer client.stream.close();
    var stream_buf: [1024]u8 = undefined;
    var reader = client.stream.reader(&stream_buf);
    // Here we echo back what we read directly, so the writer buffer is empty
    var writer = client.stream.writer(&.{});

    while (true) {
        print("Waiting for data from {f}...\n", .{client.address});
        const msg = reader.interface().takeDelimiterInclusive('\n') catch |err| {
            if (err == error.EndOfStream) {
                print("{f} closed the connection\n", .{client.address});
                return;
            } else {
                return err;
            }
        };
        print("{f} says {s}", .{ client.address, msg });
        try writer.interface.writeAll(msg);
        // No need to flush, as writer buffer is empty
    }
}
