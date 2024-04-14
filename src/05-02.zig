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

    const uri = try std.Uri.parse("http://httpbin.org/anything");

    const payload =
        \\ {
        \\  "name": "zig-cookbook",
        \\  "author": "John"
        \\ }
    ;

    var req = if (is_zig_11) blk: {
        var headers = http.Headers{ .allocator = allocator };
        defer headers.deinit();

        var req = try client.request(.POST, uri, headers, .{});
        errdefer req.deinit();

        req.transfer_encoding = .{ .content_length = payload.len };

        try req.start();
        var wtr = req.writer();
        try wtr.writeAll(payload);
        try req.finish();
        try req.wait();

        break :blk req;
    } else blk: {
        var buf: [1024]u8 = undefined;
        var req = try client.open(.POST, uri, .{ .server_header_buffer = &buf });
        errdefer req.deinit();

        req.transfer_encoding = .{ .content_length = payload.len };

        try req.send();
        var wtr = req.writer();
        try wtr.writeAll(payload);
        try req.finish();
        try req.wait();

        break :blk req;
    };
    defer req.deinit();

    try std.testing.expectEqual(req.response.status, .ok);

    var rdr = req.reader();
    const body = try rdr.readAllAlloc(allocator, 1024 * 1024 * 4);
    defer allocator.free(body);

    print("Body:\n{s}\n", .{body});
}
