//! Show Io synchronization primitives and a typed queue.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var mutex: std.Io.Mutex = .init;
    try mutex.lock(io);
    defer mutex.unlock(io);

    var read_write_lock: std.Io.RwLock = .init;
    try read_write_lock.lockShared(io);
    read_write_lock.unlockShared(io);

    var semaphore: std.Io.Semaphore = .{ .permits = 1 };
    try semaphore.wait(io);
    semaphore.post(io);

    var event: std.Io.Event = .unset;
    event.set(io);
    const event_ready = event.isSet();
    event.reset();

    var queue_storage: [4]u32 = undefined;
    var queue = std.Io.Queue(u32).init(&queue_storage);
    try queue.putOne(io, 10);
    try queue.putOne(io, 20);
    const first = try queue.getOne(io);
    const second = try queue.getOne(io);
    queue.close(io);

    std.debug.print("event ready: {any}, reset: {any}\n", .{ event_ready, !event.isSet() });
    std.debug.print("queue values: {d}, {d}\n", .{ first, second });
}
