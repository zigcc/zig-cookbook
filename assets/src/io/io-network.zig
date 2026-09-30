//! Resolve a host through the std.Io.net interface.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const host_name = try std.Io.net.HostName.init("localhost");
    var queue_storage: [16]std.Io.net.HostName.LookupResult = undefined;
    var resolved = std.Io.Queue(std.Io.net.HostName.LookupResult).init(&queue_storage);

    std.Io.net.HostName.lookup(host_name, io, &resolved, .{ .port = 80 }) catch |err| {
        std.debug.print("lookup failed: {s}\n", .{@errorName(err)});
        return;
    };

    while (true) {
        const result = resolved.getOne(io) catch |err| switch (err) {
            error.Closed => break,
            error.Canceled => return error.Canceled,
        };
        switch (result) {
            .address => |address| std.debug.print("address: {any}\n", .{address}),
            .canonical_name => |canonical_name| {
                std.debug.print("canonical name: {s}\n", .{canonical_name.bytes});
            },
        }
    }
}
