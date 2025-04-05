// reference: https://pismice.github.io/HEIG_ZIG/docs/web/std-http/
const std = @import("std");

pub fn main() !void {
    const addr = try std.net.Address.parseIp("127.0.0.1", 8080);
    var server = try std.net.Address.listen(addr, .{ .reuse_address = true });

    var buf: [1024]u8 = undefined;
    const conn = try server.accept();

    var client = std.http.Server.init(conn, &buf);

    while (client.state == .ready) {
        var request = client.receiveHead() catch |err| switch (err) {
            std.http.Server.ReceiveHeadError.HttpConnectionClosing => break,
            else => return err,
        };
        _ = try request.reader();

        try request.respond("Hello http.std!", .{});
    }
}
