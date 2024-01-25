const std = @import("std");
const Thread = std.Thread;
const Mutex = Thread.Mutex;

const SharedData = struct {
    mutex: Mutex,
    value: i32,

    pub fn updateValue(self: *SharedData, increment: i32) void {
        // Use `tryLock` if you don't want to block
        self.mutex.lock();
        defer self.mutex.unlock();

        for (0..100) |_| {
            self.value += increment;
        }
    }
};

pub fn main() !void {
    var shared_data = SharedData{ .mutex = Mutex{}, .value = 0 };
    const t1 = try Thread.spawn(.{}, SharedData.updateValue, .{ &shared_data, 1 });
    const t2 = try Thread.spawn(.{}, SharedData.updateValue, .{ &shared_data, 2 });
    t1.join();
    t2.join();
    try std.testing.expectEqual(shared_data.value, 300);
}
