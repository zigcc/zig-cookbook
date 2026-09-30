const std = @import("std");
const Io = std.Io;
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var group: Io.Group = .init;
    errdefer group.cancel(io);

    for (0..10) |i| {
        group.async(io, run, .{i});
    }
    try group.await(io);

    print("All threads exit.\n", .{});
}

fn run(id: usize) void {
    print("I'm from {d}\n", .{id});
}
