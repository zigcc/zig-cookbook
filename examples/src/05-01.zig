const std = @import("std");
const print = std.debug.print;
const http = std.http;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var headers = http.Headers{ .allocator = allocator };
    defer headers.deinit();

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    const uri = try std.Uri.parse("https://ziglang.org");
    var req = try client.request(.GET, uri, headers, .{});
    defer req.deinit();

    try req.start();
    try req.wait();

    var buf: [1024]u8 = undefined;
    const n = try req.read(&buf);
    const res = req.response;

    print("Status: {}\n", .{res.status});
    print("Headers:\n{}\n", .{res.headers});
    print("Body:\n{s}\n", .{buf[0..n]});
}
