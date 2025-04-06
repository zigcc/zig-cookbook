const std = @import("std");
const log = std.log;
const WebSocket = std.http.WebSocket;
const Request = std.http.Server.Request;
const Connection = std.net.Server.Connection;

const MAX_BUF = 1024;

pub fn main() !void {
    const addr = try std.net.Address.parseIp("127.0.0.1", 8080);
    var server = try std.net.Address.listen(addr, .{ .reuse_address = true });
    defer server.deinit();

    log.info("Start HTTP server at {any}", .{addr});

    while (true) {
        const conn = server.accept() catch |err| {
            log.err("failed to accept connection: {s}", .{@errorName(err)});
            continue;
        };
        _ = std.Thread.spawn(.{}, accept, .{conn}) catch |err| {
            log.err("unable to spawn connection thread: {s}", .{@errorName(err)});
            conn.stream.close();
            continue;
        };
    }
}

fn accept(conn: Connection) !void {
    defer conn.stream.close();

    log.info("Got new client({any})!", .{conn.address});

    var read_buffer: [MAX_BUF]u8 = undefined;
    var server = std.http.Server.init(conn, &read_buffer);
    while (server.state == .ready) {
        var request = server.receiveHead() catch |err| switch (err) {
            error.HttpConnectionClosing => return,
            else => return err,
        };

        var ws: WebSocket = undefined;
        var send_buf: [MAX_BUF]u8 = undefined;
        var recv_buf: [MAX_BUF]u8 align(4) = undefined;

        if (try ws.init(&request, &send_buf, &recv_buf)) {
            // Upgrade to web socket successfully.
            serveWebSocket(&ws) catch |err| switch (err) {
                error.ConnectionClose => {
                    log.info("Client({any}) closed!", .{conn.address});
                    break;
                },
                else => return err,
            };
        } else {
            try serveHTTP(&request);
        }
    }
}

fn serveHTTP(request: *Request) !void {
    try request.respond(
        "Hello World from Zig HTTP server",
        .{
            .extra_headers = &.{
                .{ .name = "custom header", .value = "custom value" },
            },
        },
    );
}

fn serveWebSocket(ws: *WebSocket) !void {
    try ws.writeMessage("Message from zig", .text);
    while (true) {
        const msg = try ws.readSmallMessage();
        try ws.writeMessage(msg.data, msg.opcode);
    }
}
