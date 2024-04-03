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

    const uri = try std.Uri.parse("http://httpbin.org/image/jpeg");

    var req = if (is_zig_11) blk: {
        var headers = http.Headers{ .allocator = allocator };
        defer headers.deinit();

        var req = try client.request(.GET, uri, headers, .{});
        errdefer req.deinit();

        try req.start();
        try req.wait();

        break :blk req;
    } else blk: {
        const buf = try allocator.alloc(u8, 1024 * 1024 * 4);
        defer allocator.free(buf);
        var req = try client.open(.GET, uri, .{
            .server_header_buffer = buf,
        });
        errdefer req.deinit();

        try req.send(.{});
        try req.finish();
        try req.wait();

        break :blk req;
    };
    defer req.deinit();

    try std.testing.expectEqual(req.response.status, .ok);

    var rdr = req.reader();
    const content = try rdr.readAllAlloc(allocator, 1024 * 1024 * 4);
    defer allocator.free(content);

    const file_name = "image.jpeg";
    const file = try std.fs.cwd().createFile(
        file_name,
        .{},
    );
    defer file.close();
    try file.writeAll(content);
    try std.fs.cwd().deleteFile(file_name);
}
