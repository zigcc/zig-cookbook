const std = @import("std");
const Thread = std.Thread;
const WaitGroup = Thread.WaitGroup;
const spawn = Thread.spawn;

const SharedData = struct {
    value: i32,
};

var shared_data = SharedData{ .value = 0 };

pub fn threadFunc(wg: *WaitGroup, increment: usize) void {
    std.debug.print("Thread started with increment: {}\n", .{increment});

    for (0..100) |_| {
        shared_data.value += @intCast(increment);
    }

    wg.finish();
    std.debug.print("Thread finished with increment: {}\n", .{increment});
}

pub fn main() !void {
    var wg = WaitGroup{};
    wg.reset();

    const num_threads = 4;
    var threads: [num_threads]Thread = undefined;

    for (threads[0..], 0..num_threads) |*t, index| {
        wg.start();
        std.debug.print("Starting thread {}\n", .{index});

        t.* = try spawn(.{}, threadFunc, .{
            &wg, index * 10,
        });
    }

    wg.wait();
    std.debug.print("All threads have started, waiting for completion\n", .{});

    for (threads[0..], 0..num_threads) |*t, index| {
        t.join();
        std.debug.print("Joined thread {}\n", .{index});
    }

    std.debug.print("Finally shared_data value is {}\n", .{shared_data.value});
}
