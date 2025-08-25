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

    const payload =
        \\ {
        \\  "name": "zig-cookbook",
        \\  "author": "John"
        \\ }
    ;

    var buf: [1024]u8 = undefined;
    var req = try client.open(.POST, uri, .{ .server_header_buffer = &buf });
    defer req.deinit();

    req.transfer_encoding = .{ .content_length = payload.len };
    try req.send();
    var wtr = req.writer();
    try wtr.writeAll(payload);
    try req.finish();
    try req.wait();

    // Occasionally, httpbin might time out, so we disregard cases
    // where the response status is not okay.
    if (req.response.status != .ok) {
        return;
    }

    var rdr = req.reader();
    const body = try rdr.readAllAlloc(allocator, 1024 * 1024 * 4);
    defer allocator.free(body);

    print("Body:\n{s}\n", .{body});
}
