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
    const buf = try allocator.alloc(u8, 1024 * 8);
    defer allocator.free(buf);
    var req = try client.request(.GET, uri, .{
        .extra_headers = &.{.{ .name = "Custom-header", .value = "Custom Value" }},
    });
    defer req.deinit();

    try req.sendBodiless();

    var redirect_buffer: [1024]u8 = undefined;
    var response = try req.receiveHead(&redirect_buffer);
    var iter = response.head.iterateHeaders();
    while (iter.next()) |header| {
        std.debug.print("Name:{s}, Value:{s}\n", .{ header.name, header.value });
    }

    try std.testing.expectEqual(response.head.status, .ok);
    const body = try response.reader(&.{}).allocRemaining(allocator, .unlimited);
    defer allocator.free(body);

    print("Body:\n{s}\n", .{body});
}
