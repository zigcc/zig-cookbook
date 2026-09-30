//! Use std.Io.Reader and std.Io.Writer with an in-memory byte stream.

const std = @import("std");

pub fn main() !void {
    var encoded: [128]u8 = undefined;
    var writer = std.Io.Writer.fixed(&encoded);
    try writer.print("id={d}; active={any}\n", .{ 42, true });

    var reader = std.Io.Reader.fixed(encoded[0..writer.end]);
    const line = try reader.takeDelimiter('\n');
    std.debug.print("decoded: {s}", .{line.?});
}
