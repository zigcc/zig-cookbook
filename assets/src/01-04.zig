//! Test file/directory existence

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const filename = "build.zig";
    var found = true;
    std.Io.Dir.cwd().access(io, filename, .{}) catch |e| switch (e) {
        error.FileNotFound => found = false,
        else => return e,
    };

    std.debug.assert(found);
}
