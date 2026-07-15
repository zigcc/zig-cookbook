const std = @import("std");

const filename = "/tmp/zig-cookbook-01-02.txt";

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const file = try std.Io.Dir.cwd().createFile(io, filename, .{
        .read = true,
        .truncate = true,
        .exclusive = false, // Set to true will ensure this file is created by us
    });
    defer file.close(io);
    const content_to_write = "hello zig cookbook";

    // Before mapping the memory, we need to ensure file isn't empty
    try file.setLength(io, content_to_write.len);

    const length = try file.length(io);
    try std.testing.expectEqual(length, content_to_write.len);

    var mm = try file.createMemoryMap(io, .{ .len = content_to_write.len });
    defer mm.destroy(io);

    // Write file via mapped memory
    std.mem.copyForwards(u8, mm.memory, content_to_write);
    // Synchronize the mapped memory with the file (store it to the file)
    try mm.write(io);

    // Synchronize memory with contents of file
    try mm.read(io);
    // Read via mapped memory
    try std.testing.expectEqualStrings(content_to_write, mm.memory);
}
