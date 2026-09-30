const std = @import("std");
const time = std.time;
const Io = std.Io;
const print = std.debug.print;

fn expensiveFunction(io: Io) !void {
    // sleep 500ms
    try Io.sleep(io, .fromMilliseconds(500), .awake);
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // Method 1: Two timestamps on the awake (monotonic) clock.
    const start = Io.Clock.awake.now(io);
    try expensiveFunction(io);
    const end = Io.Clock.awake.now(io);
    const elapsed1: f64 = @floatFromInt(start.durationTo(end).nanoseconds);
    print("Time elapsed is: {d:.3}ms\n", .{
        elapsed1 / time.ns_per_ms,
    });

    // Method 2: Timestamp.untilNow
    const before = Io.Clock.awake.now(io);
    try expensiveFunction(io);
    const elapsed2: f64 = @floatFromInt(before.untilNow(io, .awake).nanoseconds);
    print("Time elapsed is: {d:.3}ms\n", .{
        elapsed2 / time.ns_per_ms,
    });
}
