const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const is_zig_11 = @import("builtin").zig_version.minor == 11;

const filename = "/tmp/zig-cookbook-01-02.txt";

pub fn main() !void {
    if (.windows == @import("builtin").os.tag) {
        std.debug.print("MMap is not supported in Windows\n", .{});
        return;
    }

    const file = try fs.cwd().createFile(filename, .{
        .read = true,
        .truncate = true,
        .exclusive = false, // Set to true will ensure this file is created by us
    });
    defer file.close();
    const content_to_write = "hello zig cookbook";

    // Before mmap, we need to ensure file isn't empty
    try file.setEndPos(content_to_write.len);

    const md = try file.metadata();
    try std.testing.expectEqual(md.size(), content_to_write.len);

    const ptr = if (is_zig_11)
        try std.os.mmap(
            null,
            content_to_write.len,
            std.os.PROT.READ | std.os.PROT.WRITE,
            std.os.MAP.SHARED,
            file.handle,
            0,
        )
    else
        try std.posix.mmap(
            null,
            content_to_write.len,
            std.posix.PROT.READ | std.posix.PROT.WRITE,
            .{ .TYPE = .SHARED },
            file.handle,
            0,
        );

    defer if (is_zig_11) {
        std.os.munmap(ptr);
    } else {
        std.posix.munmap(ptr);
    };

    // Write file via mmap
    std.mem.copyForwards(u8, ptr, content_to_write);

    // Read file via mmap
    try std.testing.expectEqualStrings(content_to_write, ptr);
}
