const std = @import("std");
const Thread = std.Thread;
const Event = std.event;
// const Channel = Event.Channel; // TODO: After Publish Async to make this work
const Mutex = Thread.Mutex;
const Condition = Thread.Condition;
const spawn = Thread.spawn;

const SelectOp = enum {
    Send,
    Recv,
};

const SelectCase = struct {
    op: SelectOp,
    channel: *Channel(i32),
    value: ?i32,
    is_ready: bool,
};

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
        select_cases: std.ArrayList(*SelectCase), // support select usage

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
                .select_cases = std.ArrayList(*SelectCase).init(std.heap.page_allocator),
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

        pub fn send_nb(self: *Self, item: T) bool {
            self.mutex.lock();
            defer self.mutex.unlock();

            if (self.count == self.buffer.len) {
                return false; // buffer is full
            }

            self.buffer[self.end] = item;
            self.end = (self.end + 1) % self.buffer.len;
            self.count += 1;
            self.not_empty.signal();

            return true;
        }

        pub fn recv_nb(self: *Self) ?T {
            self.mutex.lock();
            defer self.mutex.unlock();

            if (self.count == 0) {
                return null; // buffer is empty
            }

            const item = self.buffer[self.start];
            self.start = (self.start + 1) % self.buffer.len;
            self.count -= 1;
            self.not_full.signal();

            return item;
        }

        pub fn registerSelectCase(self: *Self, case: *SelectCase) !void {
            self.mutex.lock();
            defer self.mutex.unlock();

            try self.select_cases.append(case);
        }

        pub fn trySelectOperation(self: *Self) bool {
            for (self.select_cases.items) |case| {
                switch (case.op) {
                    .Send => {
                        if (case.value != null and self.send_nb(case.value.?)) {
                            return true;
                        }
                    },
                    .Recv => {
                        if (self.recv_nb()) |item| {
                            case.value = item;
                            case.is_ready = true;

                            return true;
                        } else {
                            continue;
                        }
                    },
                }
            }

            return false;
        }
    };
}

pub fn select(cases: []SelectCase) !void {
    var done = false;

    // 1. register all cases
    for (cases) |*case| try case.channel.registerSelectCase(case);

    // 2. execution
    while (!done) {
        for (cases) |*case| {
            if (case.channel.trySelectOperation()) {
                case.is_ready = true;
                done = true;

                if (case.op == .Recv) {
                    std.debug.print("Received value: {?}\n", .{case.value});
                }

                break;
            }
        }
    }

    // 3. clean up
    for (cases) |*case| {
        var i: usize = 0;

        while (i < case.channel.select_cases.items.len) {
            if (case.channel.select_cases.items[i] == case) {
                _ = case.channel.select_cases.swapRemove(i);
            } else {
                i += 1;
            }
        }
    }
}

fn producer(ch: anytype) void {
    std.debug.print("Producer starting...\n", .{});

    for (0..5) |i| {
        std.debug.print("Sending: {}\n", .{i});
        ch.put(@intCast(i));
        std.debug.print("Sent: {}\n", .{i});
    }
}

fn consumer(ch: anytype) void {
    for (0..5) |_| {
        const v = ch.get();
        std.debug.print("Received: {}\n", .{v});
    }
}

pub fn blockChannel() !void {
    var channel: Channel(i32) = undefined;
    var buffer: [5]i32 = undefined;

    channel.init(buffer[0..]);
    defer channel.deinit();

    std.debug.print("Channel initialized\n", .{});
    std.debug.print("Start two threads..\n", .{});
    // start the producer and consumer threads
    const producerThread = try spawn(.{}, producer, .{&channel});
    const consumerThread = try spawn(.{}, consumer, .{&channel});

    // wait for the threads to finish
    producerThread.join();
    consumerThread.join();

    std.debug.print("Done!\n", .{});
}

pub fn selectChannelData(channel: *Channel(i32)) !void {
    // select
    var cases: [2]SelectCase = undefined;
    var select_count: usize = 0;
    var attemptsTrack: usize = 0;

    while (attemptsTrack < 2) {
        if (channel.count < channel.buffer.len) {
            cases[0] = SelectCase{
                .op = .Send,
                .channel = channel,
                .value = 200,
                .is_ready = false,
            };

            select_count += 1;
        }

        cases[1] = SelectCase{
            .op = .Recv,
            .channel = channel,
            .value = null,
            .is_ready = false,
        };
        select_count += 1;

        try select(cases[0..]);

        for (cases) |case| {
            if (case.is_ready) {
                switch (case.op) {
                    .Send => {
                        const sent = channel.send_nb(100);
                        if (sent) {
                            std.debug.print("{} Send value: {}\n", .{ Thread.getCurrentId(), case.value.? });
                        } else {
                            std.debug.print("{} Send failed, channel is full.\n", .{Thread.getCurrentId()});
                        }
                    },
                    .Recv => {
                        const received = channel.recv_nb();
                        if (received != null) {
                            std.debug.print("{} Received value: {?}\n", .{ Thread.getCurrentId(), received });
                        } else {
                            std.debug.print("Receive failed, channel is empty.\n", .{});
                        }
                    },
                }

                attemptsTrack += 1;
            }
        }

        select_count = 0;
    }
}

pub fn nonBlockingChannel() !void {
    var channel: Channel(i32) = undefined;
    var buffer: [10]i32 = undefined;

    channel.init(buffer[0..]);
    defer channel.deinit();

    const threadCount = 10;

    for (threadCount) |_| {
        const thread = try spawn(.{}, selectChannelData, .{
            &channel,
        });
        thread.join();
    }
}

pub fn main() !void {
    try blockChannel();
    try nonBlockingChannel();
}
