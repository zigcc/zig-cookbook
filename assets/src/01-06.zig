//! Create, copy, rename, and remove a small file and directory tree.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const cwd = std.Io.Dir.cwd();
    const root = "zig-cookbook-file-ops";
    const source = root ++ "/source.txt";
    const copy = root ++ "/copy.txt";

    try cwd.createDir(io, root, .default_dir);
    defer cwd.deleteTree(io, root) catch |err| {
        std.log.err("failed to remove example directory: {t}", .{err});
    };

    const file = try cwd.createFile(io, source, .{});
    try file.writeStreamingAll(io, "created by Zig\n");
    file.close(io);

    try cwd.copyFile(source, cwd, copy, io, .{});
    try cwd.rename(copy, cwd, root ++ "/renamed.txt", io);
    std.debug.print("created, copied, renamed, and ready to remove {s}\n", .{root});
}
