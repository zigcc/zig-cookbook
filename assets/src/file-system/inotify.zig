const builtin = @import("builtin");
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    _ = init;
    if (comptime builtin.os.tag == .linux) {
        try watchWithInotify();
    } else {
        std.debug.print("This example requires Linux.\n", .{});
    }
}

fn watchWithInotify() !void {
    const linux = std.os.linux;
    const descriptor_result = linux.inotify_init1(linux.IN.CLOEXEC);
    if (linux.errno(descriptor_result) != .SUCCESS) {
        return std.posix.unexpectedErrno(linux.errno(descriptor_result));
    }
    const descriptor: std.posix.fd_t = @intCast(descriptor_result);
    defer std.Io.Threaded.closeFd(descriptor);

    const mask = linux.IN.MODIFY | linux.IN.CREATE | linux.IN.DELETE | linux.IN.MOVE;
    const watch_result = linux.inotify_add_watch(descriptor, ".", mask);
    if (linux.errno(watch_result) != .SUCCESS) {
        return std.posix.unexpectedErrno(linux.errno(watch_result));
    }
    const watch: i32 = @intCast(watch_result);

    var buffer: [4096]u8 align(@alignOf(linux.inotify_event)) = undefined;
    std.debug.print("Waiting for a change in the current directory...\n", .{});
    const bytes_read = try std.posix.read(descriptor, &buffer);
    if (bytes_read < @sizeOf(linux.inotify_event)) return error.InvalidEvent;

    const event: *const linux.inotify_event = @ptrCast(&buffer);
    std.debug.print("directory event (mask: 0x{x})", .{event.mask});
    if (event.getName()) |name| {
        std.debug.print(": {s}", .{name});
    }
    std.debug.print("\n", .{});

    const remove_result = linux.inotify_rm_watch(descriptor, watch);
    if (linux.errno(remove_result) != .SUCCESS) {
        return std.posix.unexpectedErrno(linux.errno(remove_result));
    }
}
