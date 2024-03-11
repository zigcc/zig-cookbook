const std = @import("std");
const Allocator = std.mem.Allocator;

fn DoublyLinkedList(comptime T: type) type {
    return struct {
        const Node = struct {
            data: T,
            next: ?*Node = null,
            prev: ?*Node = null,
        };

        const Self = @This();

        head: ?*Node = null,
        tail: ?*Node = null,
        len: usize = 0,
        allocator: Allocator,

        fn init(allocator: Allocator) Self {
            return .{ .allocator = allocator };
        }

        // This function is equals to self.insertAt(self.len, value)
        // But this cost O(1), while insertAt cost O(n) .
        fn insertLast(self: *Self, value: T) !void {
            const node = try self.allocator.create(Node);
            node.* = Node{ .data = value, .prev = self.tail };
            if (self.tail) |tail| {
                tail.*.next = node;
            } else {
                self.head = node;
            }

            self.tail = node;
            self.len += 1;
        }

        fn insertAt(self: *Self, position: usize, value: T) !void {
            if (position > self.len) {
                return error.OutOfRange;
            }
            defer self.len += 1;

            const node = try self.allocator.create(Node);
            node.* = Node{ .data = value };

            var current = self.head;
            // Find the node which is specified by the position
            for (0..position) |_| {
                if (current) |cur| {
                    current = cur.next;
                }
            }

            // Put node in front of current
            node.next = current;
            if (current) |cur| {
                node.*.prev = cur.prev;

                if (cur.prev) |*prev| {
                    prev.*.next = node;
                } else {
                    // When current has no prev, we are insert at head.
                    self.head = node;
                }

                cur.*.prev = node;
            } else { // We are insert at tail, update node to new tail.
                if (self.tail) |tail| {
                    node.*.prev = tail;
                    tail.*.next = node;
                }
                self.tail = node;
                // Head may also be null for an empty list
                if (null == self.head) {
                    self.head = node;
                }
            }
        }

        fn remove(self: *Self, value: T) bool {
            var current = self.head;

            while (current) |cur| : (current = cur.next) {
                if (cur.data == value) {
                    // if the current node has a previous node
                    // then set the previous node's next to the current node's next
                    if (cur.prev) |prev| {
                        prev.next = cur.next;
                    } else {
                        // if the current node has no previous node
                        self.head = cur.next;
                    }

                    // if the current node has a next node
                    // then set the next node's previous to the current node's previous
                    if (cur.next) |next| {
                        next.prev = cur.prev;
                    } else {
                        //  if the current node has no next node
                        // then set the tail to the current node's previous
                        self.tail = cur.prev;
                    }

                    self.allocator.destroy(cur);
                    self.len -= 1;

                    return true;
                }
            }

            return false;
        }

        fn len(self: *Self) usize {
            return self.len;
        }

        fn search(self: *Self, value: T) bool {
            var current: ?*Node = self.head;

            while (current) |cur| : (current = cur.next) {
                if (cur.data == value) {
                    return true;
                }
            }

            return false;
        }

        fn visit(self: Self, visitor: *const fn (i: usize, v: T) anyerror!void) !usize {
            var current: ?*Node = self.head;
            var i: usize = 0;

            while (current) |cur| : (i += 1) {
                try visitor(i, cur.data);
                current = cur.next;
            }

            return i;
        }

        fn visitBackwards(self: Self, visitor: *const fn (i: usize, v: T) anyerror!void) !usize {
            var current = self.tail;
            var i: usize = 0;

            while (current) |cur| : (i += 1) {
                try visitor(i, cur.data);
                current = cur.prev;
            }
            return i;
        }

        fn deinit(self: *Self) void {
            var current = self.head;
            while (current) |cur| {
                const next = cur.next;
                self.allocator.destroy(cur);

                current = next;
            }

            self.head = null;
            self.tail = null;
            self.len = 0;
        }
    };
}

fn ensureList(lst: DoublyLinkedList(u32), comptime expected: []const u32) !void {
    const visited_times = try lst.visit(struct {
        fn visitor(i: usize, v: u32) !void {
            if (expected.len == 0) {
                unreachable;
            } else {
                try std.testing.expectEqual(v, expected[i]);
            }
        }
    }.visitor);
    try std.testing.expectEqual(visited_times, expected.len);

    const visited_times2 = try lst.visitBackwards(struct {
        fn visitor(i: usize, v: u32) !void {
            if (expected.len == 0) {
                unreachable;
            } else {
                try std.testing.expectEqual(v, expected[expected.len - i - 1]);
            }
        }
    }.visitor);
    try std.testing.expectEqual(visited_times2, expected.len);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var list = DoublyLinkedList(u32).init(allocator);
    defer list.deinit();

    const values = [_]u32{ 1, 2, 3, 4, 5 };

    for (values) |value| {
        try list.insertLast(value);
    }
    try ensureList(list, &values);

    try list.insertAt(1, 100);
    try ensureList(list, &[_]u32{ 1, 100, 2, 3, 4, 5 });

    try list.insertAt(0, 200);
    try ensureList(list, &[_]u32{ 200, 1, 100, 2, 3, 4, 5 });

    try std.testing.expect(list.remove(100));
    try ensureList(list, &[_]u32{ 200, 1, 2, 3, 4, 5 });

    // delete all
    for (values) |value| {
        try std.testing.expect(list.remove(value));
    }
    try std.testing.expect(list.remove(200));
    try ensureList(list, &[_]u32{});
}
