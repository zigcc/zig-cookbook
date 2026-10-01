//! Demonstrate dynamic array operations with std.ArrayList in Zig.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    // std.ArrayList(T) is unmanaged by default and initialized with .empty.
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa);

    // Append single elements
    try list.append(gpa, 10);
    try list.append(gpa, 20);

    // Append multiple elements at once
    try list.appendSlice(gpa, &.{ 30, 40, 50 });

    std.debug.print("Initial items: {any}\n", .{list.items});
    try std.testing.expectEqual(5, list.items.len);

    // Insert at index 1: moves elements to make room (O(N))
    try list.insert(gpa, 1, 15);
    std.debug.print("After inserting 15 at index 1: {any}\n", .{list.items});

    // Remove element at index 1 preserving order (O(N))
    const removed = list.orderedRemove(1);
    try std.testing.expectEqual(15, removed);

    // Remove element at index 0 without preserving order (O(1), swaps with last element)
    const swapped = list.swapRemove(0);
    try std.testing.expectEqual(10, swapped);
    std.debug.print("After swapRemove(0): {any}\n", .{list.items});

    // Pop the last element
    const popped = list.pop();
    try std.testing.expectEqual(40, popped.?);

    std.debug.print("Final items: {any}\n", .{list.items});
}
