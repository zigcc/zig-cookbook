const std = @import("std");
const Allocator = std.mem.Allocator;

fn LinkedList(comptime T: type) type {
    return struct {
        const Node = struct {
            data: T,
            next: ?*Node = null,
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
            node.* = .{ .data = value };

            if (self.tail) |*tail| {
                tail.*.next = node;
                tail.* = node;
            } else {
                self.head = node;
                self.tail = node;
            }

            self.len += 1;
        }

        fn remove(self: *Self, value: T) bool {
            if (self.head == null) {
                return false;
            }

            // In this loop, we are trying to find the node that contains the value.
            // We need to keep track of the previous node to update the tail pointer if necessary.
            var current = self.head;
            var previous: ?*Node = null;
            while (current) |cur| : (current = cur.next) {
                if (cur.data == value) {
                    // If the current node is the head, point head to the next node.
                    if (self.head.? == cur) {
                        self.head = cur.next;
                    }
                    // If the current node is the tail, point tail to its previous node.
                    if (self.tail.? == cur) {
                        self.tail = previous;
                    }
                    // Skip the current node and update the previous node to point to the next node.
                    if (previous) |*prev| {
                        prev.*.next = cur.next;
                    }
                    self.allocator.destroy(cur);
                    self.len -= 1;
                    return true;
                }

                previous = cur;
            }

            return false;
        }

        fn search(self: *Self, value: T) bool {
            var head: ?*Node = self.head;
            while (head) |h| : (head = h.next) {
                if (h.data == value) {
                    return true;
                }
            }
            return false;
        }

        fn visit(self: *Self, visitor: *const fn (i: usize, v: T) anyerror!void) !usize {
            var head = self.head;
            var i: usize = 0;
            while (head) |n| : (i += 1) {
                try visitor(i, n.data);
                head = n.next;
            }

            return i;
        }

        fn deinit(self: *Self) void {
            var current = self.head;
            while (current) |n| {
                const next = n.next;
                self.allocator.destroy(n);
                current = next;
            }
            self.head = null;
            self.tail = null;
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lst = LinkedList(u32).init(allocator);
    defer lst.deinit();

    const values = [_]u32{ 32, 20, 21 };
    for (values) |v| {
        try lst.add(v);
    }

    try std.testing.expectEqual(lst.len, values.len);
    try std.testing.expectEqual(
        3,
        try lst.visit(struct {
            fn visitor(i: usize, v: u32) !void {
                try std.testing.expectEqual(values[i], v);
            }
        }.visitor),
    );

    try std.testing.expect(lst.search(20));

    // Test delete head
    try std.testing.expect(lst.remove(32));
    try std.testing.expectEqual(
        2,
        try lst.visit(struct {
            fn visitor(i: usize, v: u32) !void {
                try std.testing.expectEqual(([_]u32{ 20, 21 })[i], v);
            }
        }.visitor),
    );

    // Test delete tail
    try std.testing.expect(lst.remove(21));
    try std.testing.expectEqual(
        1,
        try lst.visit(struct {
            fn visitor(i: usize, v: u32) !void {
                try std.testing.expectEqual(([_]u32{20})[i], v);
            }
        }.visitor),
    );

    // Test delete head and tail at the same time
    try std.testing.expect(lst.remove(20));
    try std.testing.expectEqual(
        0,
        try lst.visit(struct {
            fn visitor(_: usize, _: u32) !void {
                unreachable;
            }
        }.visitor),
    );

    try std.testing.expectEqual(lst.len, 0);
}
