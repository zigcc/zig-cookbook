const std = @import("std");
const log = std.log;
const net = std.Io.net;
const Io = std.Io;
const Request = std.http.Server.Request;

const MAX_BUF = 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const addr = try net.IpAddress.parse("127.0.0.1", 8080);
    var server = try addr.listen(io, .{ .reuse_address = true });
    defer server.deinit(io);

    log.info("Start HTTP server at {f}", .{addr});

    while (true) {
        const stream = server.accept(io) catch |err| {
            log.err("failed to accept connection: {s}", .{@errorName(err)});
            continue;
        };
        const thread = std.Thread.spawn(.{}, accept, .{ stream, io }) catch |err| {
            log.err("unable to spawn connection thread: {s}", .{@errorName(err)});
            stream.close(io);
            continue;
        };
        thread.detach();
    }
}

fn accept(stream: net.Stream, io: Io) !void {
    defer stream.close(io);

    log.info("Got new client!", .{});

    var recv_buffer: [1024]u8 = undefined;
    var send_buffer: [100]u8 = undefined;
    var stream_reader = stream.reader(io, &recv_buffer);
    var stream_writer = stream.writer(io, &send_buffer);
    var server = std.http.Server.init(&stream_reader.interface, &stream_writer.interface);
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
