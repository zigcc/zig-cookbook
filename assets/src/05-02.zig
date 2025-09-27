const std = @import("std");
const print = std.debug.print;
const http = std.http;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    const uri = try std.Uri.parse("https://httpbin.org/anything");

    var req = try client.request(.POST, uri, .{
        .extra_headers = &.{.{ .name = "Content-Type", .value = "application/json" }},
    });
    defer req.deinit();

    var payload: [7]u8 = "[1,2,3]".*;
    try req.sendBodyComplete(&payload);
    var buf: [1024]u8 = undefined;
    var response = try req.receiveHead(&buf);

    // Occasionally, httpbin might time out, so we disregard cases
    // where the response status is not okay.
    if (response.head.status != .ok) {
        return;
    }

    const body = try response.reader(&.{}).allocRemaining(allocator, .unlimited);
    defer allocator.free(body);
    print("Body:\n{s}\n", .{body});
}
