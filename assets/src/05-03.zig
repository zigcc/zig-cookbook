const std = @import("std");
const log = std.log;
const Request = std.http.Server.Request;
const Connection = std.net.Server.Connection;

const MAX_BUF = 1024;

pub fn main() !void {
    const addr = try std.net.Address.parseIp("127.0.0.1", 8080);
    var server = try std.net.Address.listen(addr, .{ .reuse_address = true });
    defer server.deinit();

    log.info("Start HTTP server at {f}", .{addr});

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

    log.info("Got new client({f})!", .{conn.address});

    var recv_buffer: [1024]u8 = undefined;
    var send_buffer: [100]u8 = undefined;
    var connection_br = conn.stream.reader(&recv_buffer);
    var connection_bw = conn.stream.writer(&send_buffer);
    var server = std.http.Server.init(connection_br.interface(), &connection_bw.interface);
    while (server.reader.state == .ready) {
        var request = server.receiveHead() catch |err| switch (err) {
            error.HttpConnectionClosing => return,
            else => return err,
        };

        switch (request.upgradeRequested()) {
            .other => |other_protocol| {
                log.err("Not supported protocol, {s}", .{other_protocol});
                return;
            },
            .websocket => |key| {
                var ws = try request.respondWebSocket(.{ .key = key orelse "" });
                try serveWebSocket(&ws);
            },
            .none => {
                try serveHTTP(&request);
            },
        }
    }
}

fn serveHTTP(request: *Request) !void {
    try request.respond(
        "Hello World from Zig HTTP server",
        .{
            .extra_headers = &.{
                .{ .name = "custom-header", .value = "custom value" },
            },
        },
    );
}

fn serveWebSocket(ws: *std.http.Server.WebSocket) !void {
    try ws.writeMessage("Hello from Zig WebSocket server", .text);
    while (true) {
        const msg = try ws.readSmallMessage();
        if (msg.opcode == .connection_close) {
            log.info("Client closed the WebSocket", .{});
            return;
        }
        try ws.writeMessage(msg.data, msg.opcode);
    }
}
