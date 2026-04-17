const std = @import("std");

const filename = "/tmp/zig-cookbook-01-02.txt";

pub fn main(init: std.process.Init) !void {
    if (.windows == @import("builtin").os.tag) {
        std.debug.print("MMap is not supported in Windows\n", .{});
        return;
    }

    const io = init.io;
    const file = try std.Io.Dir.cwd().createFile(io, filename, .{
        .read = true,
        .truncate = true,
        .exclusive = false, // Set to true will ensure this file is created by us
    });
    defer file.close(io);
    const content_to_write = "hello zig cookbook";

    // Before mmap, we need to ensure file isn't empty
    try file.setLength(io, content_to_write.len);

    const md = try file.stat(io);
    try std.testing.expectEqual(md.size, content_to_write.len);

    const ptr = try std.posix.mmap(
        null,
        content_to_write.len,
        .{ .READ = true, .WRITE = true },
        .{ .TYPE = .SHARED },
        file.handle,
        0,
    );
    defer std.posix.munmap(ptr);

    // Write file via mmap
    std.mem.copyForwards(u8, ptr, content_to_write);

    // Read file via mmap
    try std.testing.expectEqualStrings(content_to_write, ptr);
}
