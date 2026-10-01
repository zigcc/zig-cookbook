//! Demonstrate POSIX signal handling and graceful shutdown in Zig.

const builtin = @import("builtin");
const std = @import("std");
const posix = std.posix;
const print = std.debug.print;

// Atomic flag indicating whether a shutdown signal has been caught.
var should_exit = std.atomic.Value(bool).init(false);

// C-compatible signal handler function.
fn handleSignal(sig: posix.SIG) callconv(.c) void {
    _ = sig;
    should_exit.store(true, .monotonic);
}

pub fn main(init: std.process.Init) !void {
    if (comptime builtin.os.tag == .windows) {
        print("POSIX signals are not supported on Windows.\n", .{});
        return;
    }

    const io = init.io;

    // 1. Configure the signal action struct.
    const act: posix.Sigaction = .{
        .handler = .{ .handler = handleSignal },
        .mask = posix.sigemptyset(),
        .flags = 0,
    };

    // 2. Register signal handlers for SIGINT (Ctrl-C) and SIGTERM (kill).
    posix.sigaction(posix.SIG.INT, &act, null);
    posix.sigaction(posix.SIG.TERM, &act, null);

    print("Signal handlers registered for SIGINT and SIGTERM.\n", .{});

    // 3. For automated testing and demonstration, send SIGINT to ourselves.
    // In a real server application, the loop below would run until an external signal arrives.
    print("Simulating arrival of SIGINT signal...\n", .{});
    try posix.kill(posix.system.getpid(), posix.SIG.INT);

    // 4. Main worker loop periodically checking the shutdown flag.
    while (!should_exit.load(.monotonic)) {
        try std.Io.sleep(io, .fromMilliseconds(50), .awake);
    }

    // 5. Graceful shutdown sequence.
    print("Shutdown signal detected! Starting cleanup sequence...\n", .{});
    // In actual applications: flush logs, close open connections, commit pending transactions.
    try std.Io.sleep(io, .fromMilliseconds(20), .awake);
    print("Cleanup completed. Exiting cleanly.\n", .{});
}
