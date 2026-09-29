//! Resolve a host name to all available IP addresses.

const std = @import("std");
const Io = std.Io;
const net = Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var args = init.minimal.args.iterate();
    _ = args.skip();
    const host_text = args.next() orelse "localhost";
    const host_name = try net.HostName.init(host_text);

    var results_buffer: [16]net.HostName.LookupResult = undefined;
    var results: Io.Queue(net.HostName.LookupResult) = .init(&results_buffer);
    try net.HostName.lookup(host_name, io, &results, .{
        .port = 0,
    });

    var address_count: usize = 0;
    while (results.getOne(io)) |result| {
        switch (result) {
            .address => |address| {
                address_count += 1;
                std.debug.print("{f}\n", .{address});
            },
            .canonical_name => |canonical_name| {
                std.debug.print("canonical name: {s}\n", .{canonical_name.bytes});
            },
        }
    } else |err| switch (err) {
        error.Closed => {},
        else => return err,
    }

    if (address_count == 0) return error.NoAddressReturned;
}
