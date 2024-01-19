const std = @import("std");
const Thread = std.Thread;
const Event = std.event;
// const Channel = Event.Channel; // TODO: After Publish Async to make this work
const Mutex = Thread.Mutex;
const Condition = Thread.Condition;
const spawn = Thread.spawn;

pub fn Channel(comptime T: type) type {
    return struct {
        mutex: Mutex,
        not_empty: Condition,
        not_full: Condition,
        buffer: []i32,
        start: usize,
        end: usize,
        count: usize,
        closed: bool,

        const Self = @This();

        pub fn init(self: *Self, buffer: []T) void {
            self.* = Self{
                .mutex = Mutex{},
                .not_empty = Condition{},
                .not_full = Condition{},
                .buffer = buffer,
                .start = 0,
                .end = 0,
                .count = 0,
                .closed = false,
            };
        }

        pub fn deinit(self: *Self) void {
            self.mutex.lock();
            defer self.mutex.unlock();

            self.not_empty.broadcast();
            self.not_full.broadcast();
            self.closed = true;
            self.buffer = undefined;
            self.start = 0;
            self.end = 0;
            self.count = 0;
        }

        pub fn put(self: *Self, item: T) void {
            self.mutex.lock();
            defer self.mutex.unlock();

            while (self.count == self.buffer.len) {
                self.not_full.wait(&self.mutex);
            }

            self.buffer[self.end] = item;
            self.end = (self.end + 1) % self.buffer.len;
            self.count += 1;
            self.not_empty.signal();
        }

        pub fn get(self: *Self) T {
            self.mutex.lock();
            defer self.mutex.unlock();

            while (self.count == 0) {
                self.not_empty.wait(&self.mutex);
            }
            const item = self.buffer[self.start];
            self.start = (self.start + 1) % self.buffer.len;
            self.count -= 1;
            self.not_full.signal();

            return item;
        }
    };
}

fn producer(ch: anytype) void {
    std.debug.print("Producer starting...\n", .{});

    for (0..1000) |i| {
        std.debug.print("Sending: {}\n", .{i});
        ch.put(@intCast(i));
        std.debug.print("Sent: {}\n", .{i});
    }
}

fn consumer(ch: anytype) void {
    for (0..1000) |_| {
        const v = ch.get();
        std.debug.print("Received: {}\n", .{v});
    }
}

pub fn main() !void {
    std.debug.print("Start...\n", .{});
    var channel: Channel(i32) = undefined;
    var buffer: [5]i32 = undefined;
    channel.init(buffer[0..]);

    std.debug.print("Channel initialized\n", .{});
    defer channel.deinit();

    std.debug.print("Start two threads..\n", .{});
    // start the producer and consumer threads
    const producerThread = try spawn(.{}, producer, .{&channel});
    const consumerThread = try spawn(.{}, consumer, .{&channel});

    // wait for the threads to finish
    producerThread.join();
    consumerThread.join();

    std.debug.print("Done!\n", .{});
}
