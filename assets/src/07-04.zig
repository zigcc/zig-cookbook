const std = @import("std");

var n: u8 = 0;
var once_state: std.atomic.Value(u8) = .init(0);

fn incr() void {
    n = n + 1;
}

fn callOnce() void {
    // Zig 0.16 removed std.once. Implement once semantics with an atomic state.
    const state = once_state.load(.acquire);
    if (state == 2) return;
    if (state == 0 and once_state.cmpxchgStrong(0, 1, .acq_rel, .acquire) == null) {
        incr();
        once_state.store(2, .release);
        return;
    }
    while (once_state.load(.acquire) != 2) std.atomic.spinLoopHint();
}

fn onceIncr() void {
    // The invocations of `callOnce` are thread-safe.
    callOnce();
    callOnce();
}

pub fn main() !void {
    {
        const t1 = try std.Thread.spawn(.{}, onceIncr, .{});
        defer t1.join();
        const t2 = try std.Thread.spawn(.{}, onceIncr, .{});
        defer t2.join();
    }

    try std.testing.expectEqual(1, n);
}
