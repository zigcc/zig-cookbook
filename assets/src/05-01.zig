const std = @import("std");
const print = std.debug.print;
const http = std.http;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    var client: http.Client = .{ .allocator = gpa, .io = io };
    defer client.deinit();

    const uri = try std.Uri.parse("http://httpbin.org/headers");
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
    const body = try response.reader(&.{}).allocRemaining(gpa, .unlimited);
    defer gpa.free(body);

    print("Body:\n{s}\n", .{body});
}
