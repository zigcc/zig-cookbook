//! Frame a message on a byte stream with a four-byte length prefix.

const std = @import("std");
const Io = std.Io;

pub fn main() !void {
    const payload = "message boundaries need an explicit frame";
    var encoded: [256]u8 = undefined;
    var writer = Io.Writer.fixed(&encoded);
    try writer.writeInt(u32, payload.len, .big);
    try writer.writeAll(payload);

    var reader = Io.Reader.fixed(encoded[0..writer.end]);
    const frame_len = try reader.takeInt(u32, .big);
    if (frame_len > 256) return error.FrameTooLarge;

    var frame: [256]u8 = undefined;
    try reader.readSliceAll(frame[0..frame_len]);
    std.debug.print("received {d}-byte frame: {s}\n", .{ frame_len, frame[0..frame_len] });
}
