const std = @import("std");
const Thread = std.Thread;
const Mutex = Thread.Mutex;
const spawn = Thread.spawn;
const SpawnConfig = Thread.SpawnConfig;

const SharedData = struct {
    mutex: Mutex,
    value: i32,

    const Self = @This();

    pub fn updateValue(self: *Self, increment: i32, max_iterations: usize) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        for (0..max_iterations) |_| {
            self.value += increment;
        }

        std.debug.print("Thread {} updated value to {}\n", .{ Thread.getCurrentId(), self.value });
    }

    // tryUpdateValue attempts to update the value, but returns false if it can't
    pub fn tryUpdateValue(self: *Self, increment: i32, max_iterations: usize) bool {
        if (!self.mutex.tryLock()) {
            return false; // if we can't lock the mutex, return false
        }

        defer self.mutex.unlock();

        for (0..max_iterations) |_| {
            self.value += increment;
        }

        // while loop
        // var start_index: usize = 0;
        // while (start_index < max_iterations) : (start_index += 1) {
        //     self.value += increment;
        // }

        return true;
    }
};

// 1. pass data by multiple arguments
fn threadFuncMultipleArgs(shared_data: *SharedData, increment: i32, max_iterations: usize) void {
    // Get current thread id
    std.debug.print("Thread {} locked mutex, current value is: {}\n", .{ Thread.getCurrentId(), shared_data.value });

    shared_data.updateValue(increment, max_iterations);
}

// 2. pass data by a single struct argument
const ThreadFuncArgs = struct {
    shared_data: *SharedData,
    increment: i32,
    max_iterations: usize,
};

fn threadFunc(args: ThreadFuncArgs) void {
    // Get current thread id
    std.debug.print("Thread {} locked mutex, current value is: {}\n", .{ Thread.getCurrentId(), args.shared_data.value });

    args.shared_data.updateValue(args.increment, args.max_iterations);
}

pub fn main() !void {
    const threadConfig = SpawnConfig{
        .stack_size = 1024 * 16,
    };

    var shared_data = SharedData{
        .mutex = Mutex{},
        .value = 0,
    };

    const threadArgs1 = ThreadFuncArgs{
        .shared_data = &shared_data,
        .increment = 1,
        .max_iterations = 1000,
    };

    const threadArgs2 = ThreadFuncArgs{
        .shared_data = &shared_data,
        .increment = 3,
        .max_iterations = 1000,
    };

    const thread1 = try spawn(threadConfig, threadFunc, .{
        threadArgs1,
    });

    const thread2 = try spawn(threadConfig, threadFunc, .{threadArgs2});

    thread1.join();
    thread2.join();

    std.debug.print("Final value: {}\n", .{shared_data.value});
}

test "test threadFunc updates shared data correctly" {
    var shared_data = SharedData{
        .mutex = Mutex{},
        .value = 0,
    };

    const thread = try spawn(.{}, threadFuncMultipleArgs, .{
        &shared_data,
        1,
        50,
    });

    thread.join();

    try std.testing.expectEqual(shared_data.value, 50);
}
