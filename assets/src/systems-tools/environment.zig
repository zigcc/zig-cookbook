//! Demonstrate reading, modifying, and iterating environment variables in Zig.

const std = @import("std");
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    // Environment variables are accessible via init.environ_map,
    // which is an instance of std.process.Environ.Map.
    const env = init.environ_map;

    // 1. Read existing environment variables.
    if (env.get("PATH")) |path| {
        print("PATH is set (length: {d} bytes)\n", .{path.len});
    }

    const user_or_home = env.get("USER") orelse env.get("HOME") orelse "unknown";
    print("USER or HOME: {s}\n", .{user_or_home});

    // 2. Check if a specific variable exists.
    const has_custom_var = env.contains("MY_APP_MODE");
    print("MY_APP_MODE present initially: {}\n", .{has_custom_var});
    try std.testing.expect(!has_custom_var);

    // 3. Set or update an environment variable.
    try env.put("MY_APP_MODE", "staging");
    try std.testing.expect(env.contains("MY_APP_MODE"));
    try std.testing.expectEqualStrings("staging", env.get("MY_APP_MODE").?);
    print("Updated MY_APP_MODE: {s}\n", .{env.get("MY_APP_MODE").?});

    // 4. Iterate over environment variables.
    var count: usize = 0;
    var it = env.iterator();
    while (it.next()) |entry| {
        count += 1;
        // Print the first few entries as an example
        if (count <= 3) {
            print("Env #{d}: {s}={s}\n", .{ count, entry.key_ptr.*, entry.value_ptr.* });
        }
    }
    print("Total environment variables count: {d}\n", .{env.count()});
    try std.testing.expect(env.count() > 0);

    // 5. Remove an environment variable.
    const removed = env.orderedRemove("MY_APP_MODE");
    try std.testing.expect(removed);
    try std.testing.expect(!env.contains("MY_APP_MODE"));
    print("Successfully removed MY_APP_MODE.\n", .{});
}
