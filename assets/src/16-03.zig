//! Grow an output buffer through std.Io.Writer.Allocating.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var output: std.Io.Writer.Allocating = .init(init.gpa);
    defer output.deinit();

    try output.writer.print("The output grows as needed: {d}\n", .{2026});
    try output.writer.writeAll("The completed bytes are available after writing.\n");

    std.debug.print("{s}", .{output.written()});
}
