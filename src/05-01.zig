const std = @import("std");
const print = std.debug.print;
const http = std.http;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    const uri = try std.Uri.parse("http://httpbin.org/headers");
    const buf = try allocator.alloc(u8, 1024 * 1024 * 4);
    defer allocator.free(buf);
    var req = try client.open(.GET, uri, .{
        .server_header_buffer = buf,
    });
    defer req.deinit();

    try req.send();
    try req.finish();
    try req.wait();

    var iter = req.response.iterateHeaders();
    while (iter.next()) |header| {
        std.debug.print("Name:{s}, Value:{s}\n", .{ header.name, header.value });
    }

    try std.testing.expectEqual(req.response.status, .ok);

    var rdr = req.reader();
    const body = try rdr.readAllAlloc(allocator, 1024 * 1024 * 4);
    defer allocator.free(body);

    print("Body:\n{s}\n", .{body});
}
