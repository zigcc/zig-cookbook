//! Demonstrate memory management with std.heap.ArenaAllocator in Zig.

const std = @import("std");
const print = std.debug.print;

const Node = struct {
    value: i32,
    name: []const u8,
    children: []Node,
};

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    // 1. Initialize an ArenaAllocator wrapping the base allocator (GPA).
    // An arena manages a collection of memory allocations and frees them all together.
    var arena = std.heap.ArenaAllocator.init(gpa);
    // Free all allocated memory at once when leaving scope.
    defer arena.deinit();

    const arena_allocator = arena.allocator();

    // 2. Allocate multiple complex objects without worrying about freeing each one individually.
    const greeting = try std.fmt.allocPrint(arena_allocator, "Hello, {s}!", .{"Zig"});
    print("Formatted message: {s}\n", .{greeting});

    // 3. Construct a hierarchical tree structure with dynamic allocations.
    var children = try arena_allocator.alloc(Node, 2);
    children[0] = .{
        .value = 1,
        .name = try arena_allocator.dupe(u8, "child_left"),
        .children = &.{},
    };
    children[1] = .{
        .value = 2,
        .name = try arena_allocator.dupe(u8, "child_right"),
        .children = &.{},
    };

    const root = Node{
        .value = 0,
        .name = try arena_allocator.dupe(u8, "root"),
        .children = children,
    };

    print("Root: {s}, children count: {d}\n", .{ root.name, root.children.len });
    try std.testing.expectEqual(2, root.children.len);
    try std.testing.expectEqualStrings("child_left", root.children[0].name);

    // 4. Reusing an arena in batch or request-processing loops:
    // Resetting frees or retains capacity for the next iteration without recreating the arena.
    _ = arena.reset(.retain_capacity);

    const reused_slice = try arena_allocator.alloc(u32, 4);
    @memset(reused_slice, 42);
    print("Reused arena buffer values: {any}\n", .{reused_slice});
    try std.testing.expectEqual(42, reused_slice[0]);
}
