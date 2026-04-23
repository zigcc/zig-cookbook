const std = @import("std");
const Io = std.Io;
const Thread = std.Thread;
const Mutex = Io.Mutex;

const SharedData = struct {
    mutex: Mutex,
    value: i32,
    io: Io,

    pub fn updateValue(self: *SharedData, increment: i32) !void {
        // Use `tryLock` if you don't want to block
        try self.mutex.lock(self.io);
        defer self.mutex.unlock(self.io);

        for (0..10000) |_| {
            self.value += increment;
        }
    }
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var shared_data = SharedData{ .mutex = .init, .value = 0, .io = io };
    // This block is necessary to ensure that all threads are joined before proceeding.
    {
        const t1 = try Thread.spawn(.{}, SharedData.updateValue, .{ &shared_data, 1 });
        defer t1.join();
        const t2 = try Thread.spawn(.{}, SharedData.updateValue, .{ &shared_data, 2 });
        defer t2.join();
    }
    try std.testing.expectEqual(shared_data.value, 30_000);
}
