const std = @import("std");
const Allocator = std.mem.Allocator;

fn LinkedList(comptime T: type) type {
    return struct {
        const Node = struct {
            data: T,
            next: ?*Node = null,
        };
        root: ?*Node = null,
        allocator: Allocator,
        const Self = @This();

        fn init(allocator: Allocator) Self {
            return Self{ .allocator = allocator };
        }

        fn add(self: *Self, value: T) !void {
            const node = try self.allocator.create(Node);
            node.* = Node{ .data = value };
            if (self.root == null) {
                self.root = node;
                return;
            }

            var head: ?*Node = self.root;
            while (head) |h| {
                if (h.next == null) {
                    h.next = node;
                    return;
                }
                head = h.next;
            }
        }

        fn search(self: *Self, value: T) bool {
            var head: ?*Node = self.root;
            while (head) |h| {
                if (h.data == value) {
                    return true;
                }
                head = h.next;
            }
            return false;
        }

        fn print(self: *Self, comptime printFunc: fn (object: T) void) void {
            var head = self.root;
            while (head) |n| {
                printFunc(n.data);
                head = n.next;
            }
        }

        fn deinit(self: *Self) void {
            const alc = self.allocator;
            var node = self.root;
            while (node) |n| {
                const addr = n.next;
                alc.destroy(n);
                node = addr;
            }
        }

        fn count(self: *Self) usize {
            var counter: usize = 0;
            var node = self.root;
            while (node) |n| {
                counter += 1;
                node = n.next;
            }
            return counter;
        }
    };
}

pub fn main() !void {
    const alc = std.heap.page_allocator;

    //create linked list
    var nos = LinkedList(u32).init(alc);
    defer nos.deinit();

    //add nodes
    try nos.add(32);
    try nos.add(20);
    try nos.add(21);

    nos.print(print_numbers);

    //search
    const no_found: bool = nos.search(20);
    std.debug.print("{}", .{no_found});
}

fn print_numbers(no: u32) void {
    std.debug.print("{d}\n", .{no});
}
