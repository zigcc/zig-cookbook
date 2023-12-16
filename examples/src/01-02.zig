const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

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
    print("File size: {d}\n", .{md.size()});

    var ptr = try std.os.mmap(
        null,
        20,
        std.os.PROT.READ | std.os.PROT.WRITE,
        std.os.MAP.PRIVATE,
        file.handle,
        0,
    );
    defer std.os.munmap(ptr);

    // Write file via mmap
    std.mem.copyForwards(u8, ptr, "hello zig cookbook");

    // Read file via mmap
    print("File body: {s}\n", .{ptr});
}
