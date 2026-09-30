//! Start an echo TCP server at an unused port.
//!
//! Test with
//! echo "hello zig" | nc localhost <port>

const std = @import("std");
const net = std.Io.net;
const Io = std.Io;
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const loopback: net.IpAddress = .{ .ip4 = .loopback(0) };
    var server = try loopback.listen(io, .{
        .reuse_address = true,
    });
    defer server.deinit(io);

    const addr = server.socket.address;
    print("Listening on {f}, access this port to end the program\n", .{addr});

    const stream = try server.accept(io);
    // In real world, you'd want to handle multiple clients, probably in separate threads.
    try handleClient(stream, io);
}

fn handleClient(stream: net.Stream, io: Io) !void {
    defer stream.close(io);
    var stream_buf: [1024]u8 = undefined;
    var reader = stream.reader(io, &stream_buf);
    // Here we echo back what we read directly, so the writer buffer is empty
    var writer = stream.writer(io, &.{});

    while (true) {
        print("Waiting for data...\n", .{});
        const msg = reader.interface.takeDelimiterInclusive('\n') catch |err| {
            if (err == error.EndOfStream) {
                print("Client closed the connection\n", .{});
                return;
            } else {
                return err;
            }
        };
        print("Client says {s}", .{msg});
        try writer.interface.writeAll(msg);
        // No need to flush, as writer buffer is empty
    }
}
