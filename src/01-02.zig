const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const is_zig_11 = @import("builtin").zig_version.minor == 11;

const filename = "/tmp/zig-cookbook-01-02.txt";
const file_size = 4096;

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

    // Before mmap, we need to ensure file isn't empty
    try file.setEndPos(file_size);

    const md = try file.metadata();
    try std.testing.expectEqual(md.size(), file_size);

    const ptr = if (is_zig_11)
        try std.os.mmap(
            null,
            20,
            std.os.PROT.READ | std.os.PROT.WRITE,
            std.os.MAP.PRIVATE,
            file.handle,
            0,
        )
    else
        try std.posix.mmap(
            null,
            20,
            std.posix.PROT.READ | std.posix.PROT.WRITE,
            .{ .TYPE = .PRIVATE },
            file.handle,
            0,
        );

    defer if (is_zig_11) {
        std.os.munmap(ptr);
    } else {
        defer std.posix.munmap(ptr);
    };

    // Write file via mmap
    const body = "hello zig cookbook";
    std.mem.copyForwards(u8, ptr, body);

    // Read file via mmap
    try std.testing.expectEqualStrings(body, ptr[0..body.len]);
}
