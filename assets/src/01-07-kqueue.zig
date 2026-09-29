const builtin = @import("builtin");
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    if (comptime builtin.os.tag == .macos or builtin.os.tag == .freebsd) {
        try watchWithKqueue(init);
    } else {
        std.debug.print("This example requires macOS or a BSD system.\n", .{});
    }
}

fn watchWithKqueue(init: std.process.Init) !void {
    const io = init.io;
    const file = try std.Io.Dir.cwd().openFile(io, "build.zig", .{});
    defer file.close(io);

    const queue = std.c.kqueue();
    if (queue < 0) return error.KqueueUnavailable;
    defer std.Io.Threaded.closeFd(queue);

    const change = std.c.Kevent{
        .ident = @intCast(file.handle),
        .filter = std.c.EVFILT.VNODE,
        .flags = std.c.EV.ADD | std.c.EV.ENABLE | std.c.EV.CLEAR,
        .fflags = std.c.NOTE.WRITE | std.c.NOTE.DELETE | std.c.NOTE.RENAME,
        .data = 0,
        .udata = 0,
    };
    var changes = [_]std.c.Kevent{change};
    var events: [1]std.c.Kevent = undefined;
    std.debug.print("Waiting for a change to build.zig...\n", .{});

    const count = std.c.kevent(queue, &changes, 1, &events, 1, null);
    if (count < 0) return error.KeventFailed;
    if (count == 0) return error.NoEvent;

    std.debug.print("build.zig changed (flags: 0x{x})\n", .{events[0].fflags});
}
