const std = @import("std");
const Allocator = std.mem.Allocator;

fn DoubleLinkedList(comptime T: type) type {
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

        fn add(self: *Self, value: T) !void {
            const node = try self.allocator.create(Node);
            node.* = Node{
                .data = value,
                .prev = self.tail,
                .next = null,
            };

            if (self.tail) |*tail| {
                tail.*.next = node;
            } else {
                self.head = node;
            }
            self.tail = node;

            self.len += 1;
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

        fn visit(self: *Self, visitor: *const fn (i: usize, v: T) anyerror!void) !void {
            var current: ?*Node = self.head;
            var i: usize = 0;

            while (current) |cur| : (i += 1) {
                try visitor(i, cur.data);
                current = cur.next;
            }
        }

        fn deinit(self: *Self) void {
            var current: ?*Node = self.head;

            while (current) |cur| : (current = cur.next) {
                self.allocator.destroy(cur);
            }

            self.head = null;
            self.tail = null;
            self.len = 0;
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var list = DoubleLinkedList(u32).init(allocator);
    defer list.deinit();

    const values = [_]u32{
        1,
        2,
        3,
        4,
        5,
    };

    for (values) |value| {
        try list.add(value);
    }

    try std.testing.expectEqual(list.len, values.len);

    try list.visit(struct {
        fn visitor(i: usize, v: u32) !void {
            try std.testing.expectEqual(values[i], v);
        }
    }.visitor);

    try std.testing.expect(list.search(2));

    // delete the first element
    try std.testing.expect(list.remove(1));
    try list.visit(struct {
        fn visitor(i: usize, v: u32) !void {
            try std.testing.expectEqual(([_]u32{ 2, 3, 4, 5 })[i], v);
        }
    }.visitor);

    // delete the last element
    try std.testing.expect(list.remove(5));
    try list.visit(struct {
        fn visitor(i: usize, v: u32) !void {
            try std.testing.expectEqual(([_]u32{ 2, 3, 4 })[i], v);
        }
    }.visitor);

    // delete first and last concurrently
    try std.testing.expect(list.remove(2));
    try std.testing.expect(list.remove(4));
    try list.visit(struct {
        fn visitor(i: usize, v: u32) !void {
            try std.testing.expectEqual(([_]u32{3})[i], v);
        }
    }.visitor);

    // delete all
    try std.testing.expect(list.remove(3));
    try list.visit(struct {
        fn visitor(_: usize, _: u32) !void {
            unreachable;
        }
    }.visitor);
    try std.testing.expectEqual(list.len, 0);
}
