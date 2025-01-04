//! Check file existence

const std = @import("std");
const fs = std.fs;

pub fn main() void {
    const filename = "build.zig";
    fs.cwd().access(filename, .{}) catch {
        std.debug.panic("{s} not exists", .{filename});
    };

    std.debug.print("{s} exists", .{filename});
}
