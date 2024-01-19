const std = @import("std");
const Thread = std.Thread;
const Mutex = Thread.Mutex;
const spawn = Thread.spawn;
const SpawnConfig = Thread.SpawnConfig;

var semaphore: Thread.Semaphore = .{
    .permits = 1,
};

fn threadFunc(value: usize) void {
    std.debug.print("thread {}: starting\n", .{Thread.getCurrentId()});

    for (0..5) |_| {
        std.debug.print("Wait for semaphore\n", .{});
        semaphore.wait();
        std.debug.print("thread {}: semaphore permits before increment: {}\n", .{ Thread.getCurrentId(), semaphore.permits });

        semaphore.permits += value;
        std.debug.print("thread {}: semaphore permits after increment: {}\n", .{ Thread.getCurrentId(), semaphore.permits });
        semaphore.post();
        std.time.sleep(1 * std.time.ns_per_s);
    }
}

pub fn main() !void {
    const testNum: usize = 10;

    std.debug.print("Initial shared data value: {}\n", .{semaphore.permits});
    const thread1 = try std.Thread.spawn(.{}, threadFunc, .{testNum});
    const thread2 = try std.Thread.spawn(.{}, threadFunc, .{testNum});

    thread1.join();
    thread2.join();

    std.debug.print("Final shared data value: {}\n", .{semaphore.permits});
}
