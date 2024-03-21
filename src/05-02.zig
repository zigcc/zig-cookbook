const std = @import("std");
const print = std.debug.print;
const http = std.http;
const is_zig_11 = @import("builtin").zig_version.minor == 11;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    var uri = try std.Uri.parse("http://httpbin.org/post");

    //If any payload has to be sent in the request body
    const reqData = "{\"first\":2,\"second\":4}\n";

    var req = if (is_zig_11) blk: {
        var headers = http.Headers{ .allocator = allocator };
        defer headers.deinit();

        //additional header required to get content as JSON
        try headers.append("accept", "application/json");
        try headers.append("Content-Type", "application/json");

        var req = try client.request(.POST, uri, headers, .{});
        errdefer req.deinit();

        req.transfer_encoding = .chunked;

        try req.start();

        var wrtr = req.writer();
        try wrtr.writeAll(reqData);

        try req.finish();
        try req.wait();
        print("Headers:\n{}\n", .{req.response.headers});
        break :blk req;
    } else blk: {
        const buf = try allocator.alloc(u8, 1024 * 1024 * 4);
        defer allocator.free(buf);
        var req = try client.open(.POST, uri, .{
            .server_header_buffer = buf,
        });
        errdefer req.deinit();

        req.transfer_encoding = .chunked;

        try req.send(.{});

        var wrtr = req.writer();
        try wrtr.writeAll(reqData);

        try req.finish();
        try req.wait();

        var iter = req.response.iterateHeaders();
        while (iter.next()) |header| {
            std.debug.print("Name:{s}, Value:{s}\n", .{ header.name, header.value });
        }
        break :blk req;
    };
    defer req.deinit();

    try std.testing.expectEqual(req.response.status, .ok);

    var rdr = req.reader();
    const body = try rdr.readAllAlloc(allocator, 1024 * 1024 * 4);
    defer allocator.free(body);

    print("Body:\n{s}\n", .{body});
}
