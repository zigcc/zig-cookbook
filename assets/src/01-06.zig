//! Build and inspect paths without assuming a platform separator.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const path = try std.fs.path.join(init.gpa, &.{ "notes", "today.txt" });
    defer init.gpa.free(path);

    std.debug.print("separator: '{c}'\npath: {s}\nbasename: {s}\ndirname: {s}\n", .{
        std.fs.path.sep,
        path,
        std.fs.path.basename(path),
        std.fs.path.dirname(path) orelse ".",
    });
}
