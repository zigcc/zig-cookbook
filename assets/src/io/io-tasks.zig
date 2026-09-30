//! Combine Io async, groups, select, and cancellation.

const std = @import("std");

const RaceResult = union(enum) {
    fast: u32,
    slow: u32,
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const stdout = std.Io.File.stdout();

    var future = std.Io.async(io, add, .{ 20, 22 });
    const sum = future.await(io);

    var group: std.Io.Group = .init;
    group.async(io, groupWorker, .{ io, 1 });
    group.async(io, groupWorker, .{ io, 2 });
    try group.await(io);

    var result_buffer: [2]RaceResult = undefined;
    var select = std.Io.Select(RaceResult).init(io, &result_buffer);
    select.async(.fast, fastResult, .{});
    select.async(.slow, slowResult, .{});
    const winner = try select.await();
    select.cancelDiscard();

    var writer_buffer: [256]u8 = undefined;
    var writer = stdout.writer(io, &writer_buffer);
    try writer.interface.print("future sum: {d}\n", .{sum});
    switch (winner) {
        .fast => |value| try writer.interface.print("select winner: fast {d}\n", .{value}),
        .slow => |value| try writer.interface.print("select winner: slow {d}\n", .{value}),
    }
    try writer.interface.flush();
}

fn add(left: u32, right: u32) u32 {
    return left + right;
}

fn groupWorker(io: std.Io, worker_id: u32) std.Io.Cancelable!void {
    std.debug.assert(worker_id > 0);
    try io.checkCancel();
}

fn fastResult() u32 {
    return 1;
}

fn slowResult() u32 {
    return 2;
}
