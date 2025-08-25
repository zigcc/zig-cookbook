//! Test file/directory existence

const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    const filename = "build.zig";
    var found = true;
    fs.cwd().access(filename, .{}) catch |e| switch (e) {
        error.FileNotFound => found = false,
        else => return e,
    };

    std.debug.assert(found);
}
