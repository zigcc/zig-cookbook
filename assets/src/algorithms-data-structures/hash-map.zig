//! Demonstrate hash map operations with std.AutoHashMap in Zig 0.16.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    // std.AutoHashMap automatically provides hash and equality implementations for the key type.
    var map = std.AutoHashMap(u32, []const u8).init(gpa);
    defer map.deinit();

    // Insert key-value pairs
    try map.put(1, "Zig");
    try map.put(2, "Rust");
    try map.put(3, "C");

    // Fetch value by key
    if (map.get(1)) |val| {
        std.debug.print("Key 1: {s}\n", .{val});
        try std.testing.expectEqualStrings("Zig", val);
    }

    // Check key existence
    try std.testing.expect(map.contains(2));
    try std.testing.expect(!map.contains(99));

    // getOrPut: retrieve existing entry or insert a new one if not present
    const gop = try map.getOrPut(4);
    if (!gop.found_existing) {
        gop.value_ptr.* = "Go";
    }
    try std.testing.expectEqualStrings("Go", map.get(4).?);

    // Iterate over key-value pairs
    var it = map.iterator();
    var count: usize = 0;
    while (it.next()) |entry| {
        std.debug.print("  {d} => {s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        count += 1;
    }
    try std.testing.expectEqual(4, count);

    // Remove entry by key
    const removed = map.remove(3);
    try std.testing.expect(removed);
    try std.testing.expect(!map.contains(3));

    std.debug.print("Final map count: {d}\n", .{map.count()});
}
