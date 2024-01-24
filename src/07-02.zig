const std = @import("std");
const Thread = std.Thread;
const Mutex = Thread.Mutex;
const spawn = Thread.spawn;
const SpawnConfig = Thread.SpawnConfig;

const SharedData = struct {
    mutex: Mutex,
    value: i32,

    const Self = @This();

    pub fn updateValue(self: *Self, increment: i32) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        self.value += increment;
    }

    // tryUpdateValue attempts to update the value, but returns false if it can't
    pub fn tryUpdateValue(self: *Self, increment: i32) bool {
        if (!self.mutex.tryLock()) {
            return false; // if we can't lock the mutex, return false
        }
        defer self.mutex.unlock();

        self.value += increment;
        return true;
    }
};

// 1. pass data by multiple arguments
fn threadFuncMultipleArgs(
    shared_data: *SharedData,
    increment: i32,
) void {
    shared_data.updateValue(increment);
}

// 2. pass data by a single struct argument
const ThreadFuncArgs = struct { shared_data: *SharedData, increment: i32 };

fn threadFunc(args: ThreadFuncArgs) void {
    args.shared_data.updateValue(args.increment);
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
    };

    const threadArgs2 = ThreadFuncArgs{
        .shared_data = &shared_data,
        .increment = 3,
    };

    const thread1 = try spawn(threadConfig, threadFunc, .{
        threadArgs1,
    });

    const thread2 = try spawn(threadConfig, threadFunc, .{threadArgs2});

    thread1.join();
    thread2.join();
}

test "test threadFunc updates shared data correctly" {
    var shared_data = SharedData{
        .mutex = Mutex{},
        .value = 0,
    };

    const thread = try spawn(.{}, threadFuncMultipleArgs, .{
        &shared_data,
        1,
    });

    thread.join();

    try std.testing.expectEqual(shared_data.value, 1);
}
