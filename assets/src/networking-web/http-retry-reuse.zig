//! Retry transient HTTP failures while reusing one HTTP client.

const std = @import("std");
const http = std.http;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    const uri = try std.Uri.parse("https://httpbin.org/status/503");

    var client: http.Client = .{ .allocator = gpa, .io = io };
    defer client.deinit();

    var attempt: u8 = 0;
    while (attempt < 3) : (attempt += 1) {
        var request = try client.request(.GET, uri, .{});
        try request.sendBodiless();

        var response_buffer: [1024]u8 = undefined;
        const response = try request.receiveHead(&response_buffer);
        const status_code = @intFromEnum(response.head.status);
        std.debug.print("attempt {d}: HTTP {d}\n", .{ attempt + 1, status_code });
        request.deinit();

        if (status_code < 500) return;
    }

    std.debug.print("retry limit reached\n", .{});
}
