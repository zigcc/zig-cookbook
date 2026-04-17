const std = @import("std");
const net = std.Io.net;
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var args = init.minimal.args.iterate();
    // The first (0 index) argument is the path to the program.
    _ = args.skip();
    const port_value = args.next() orelse {
        print("expect port as command line argument\n", .{});
        return error.NoPort;
    };
    const port = try std.fmt.parseInt(u16, port_value, 10);

    const peer = try net.IpAddress.parseIp4("127.0.0.1", port);
    // Connect to peer
    const stream = try peer.connect(io, .{ .mode = .stream });
    defer stream.close(io);
    print("Connecting to {f}\n", .{peer});

    // Sending data to peer
    const data = "hello zig";
    var buffer: [1024]u8 = undefined;
    var writer = stream.writer(io, buffer[0..]);
    try writer.interface.writeAll(data);
    try writer.interface.flush();
    print("Sending '{s}' to peer, total written: {d} bytes\n", .{ data, data.len });
}
