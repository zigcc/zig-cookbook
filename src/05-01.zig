const std = @import("std");
const print = std.debug.print;
const http = std.http;
const is_zig_11 = @import("builtin").zig_version.minor == 11;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var headers = http.Headers{ .allocator = allocator };
    defer headers.deinit();

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    const uri = try std.Uri.parse("http://httpbin.org/headers");
    var req = if (is_zig_11) blk: {
        var req = try client.request(.GET, uri, headers, .{});
        errdefer req.deinit();

        try req.start();
        break :blk req;
    } else blk: {
        var req = try client.open(.GET, uri, headers, .{});
        errdefer req.deinit();

        try req.send(.{});
        break :blk req;
    };
    defer req.deinit();

    try req.wait();

    try std.testing.expectEqual(req.response.status, .ok);
    print("Headers:\n{}\n", .{req.response.headers});

    var rdr = req.reader();
    const body = try rdr.readAllAlloc(allocator, 1024 * 1024 * 4);
    defer allocator.free(body);

    print("Body:\n{s}\n", .{body});
}
