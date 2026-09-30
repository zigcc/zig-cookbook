//! Measure time and bound a wait with std.Io.Clock and std.Io.Timeout.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const sleep_duration = std.Io.Duration.fromNanoseconds(5 * std.time.ns_per_ms);

    const direct_start = std.Io.Clock.now(.awake, io);
    try std.Io.sleep(io, sleep_duration, .awake);
    const direct_elapsed = direct_start.durationTo(std.Io.Clock.now(.awake, io));

    const timeout: std.Io.Timeout = .{ .duration = .{
        .clock = .awake,
        .raw = sleep_duration,
    } };
    const timeout_start = std.Io.Clock.now(.awake, io);
    try timeout.sleep(io);
    const timeout_elapsed = timeout_start.durationTo(std.Io.Clock.now(.awake, io));

    std.debug.print("direct sleep: {d} ns\n", .{direct_elapsed.nanoseconds});
    std.debug.print("timeout sleep: {d} ns\n", .{timeout_elapsed.nanoseconds});
}
