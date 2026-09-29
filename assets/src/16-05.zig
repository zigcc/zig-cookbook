//! Measure time and bound a wait with std.Io.Clock and std.Io.Timeout.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const started = std.Io.Clock.now(.awake, io);

    const timeout: std.Io.Timeout = .{ .duration = .{
        .clock = .awake,
        .raw = .fromNanoseconds(10 * std.time.ns_per_ms),
    } };
    try timeout.sleep(io);

    const elapsed = started.durationTo(std.Io.Clock.now(.awake, io));
    std.debug.print("waited at least {d} ns\n", .{elapsed.nanoseconds});
}
