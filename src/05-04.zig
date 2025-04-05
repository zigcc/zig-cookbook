const std = @import("std");
const WebSocket = @import("std").http.WebSocket;

pub fn main() !void {
    const addr = try std.net.Address.parseIp("127.0.0.1", 8080);
    var server = try std.net.Address.listen(addr, .{ .reuse_address = true });
    defer server.deinit();

    var buf: [65535]u8 = undefined;
    const conn = try server.accept();
    defer conn.stream.close();

    var client = std.http.Server.init(conn, &buf);

    if (client.state == .ready) {
        var request = try client.receiveHead();

        var ws: WebSocket = undefined;
        var send_buf: [65535]u8 = undefined;
        var recv_buf: [65535]u8 align(4) = undefined;

        const upgrade_success = try WebSocket.init(&ws, &request, &send_buf, &recv_buf);

        if (!upgrade_success) return error.upgrade_failed;

        try ws.writeMessage("hello zig", .text);
        while (true) {
            const msg = ws.readSmallMessage() catch |err| switch (err) {
                WebSocket.ReadSmallTextMessageError.ConnectionClose => break,
                else => return err,
            };
            try ws.writeMessage(msg.data, msg.opcode);
        }
    }
}
