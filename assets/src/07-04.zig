const std = @import("std");

var n: u8 = 0;
// Three-state atomic protocol (replaces std.once which was removed in Zig 0.16):
//   0 = idle      – no thread has started the work yet
//   1 = running   – one thread is executing the payload
//   2 = done      – the payload has finished; all threads may proceed
var once_state: std.atomic.Value(u8) = .init(0);

fn incr() void {
    n = n + 1;
}

fn callOnce() void {
    const state = once_state.load(.acquire);
    if (state == 2) return; // fast path: already done
    if (state == 0 and once_state.cmpxchgStrong(0, 1, .acq_rel, .acquire) == null) {
        // We won the race (0 → 1): execute the payload, then mark done.
        incr();
        once_state.store(2, .release);
        return;
    }
    // Another thread is running (state == 1): spin until it finishes.
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
