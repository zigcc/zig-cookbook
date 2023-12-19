const std = @import("std");
const print = std.debug.print;
const Encoder = std.base64.standard.Encoder;
const Decoder = std.base64.standard.Decoder;

pub fn main() !void {
    const src = "hello zig";
    const dst_len = Encoder.calcSize(src.len);

    var encode_buffer: [1024]u8 = undefined;

    const dst = encode_buffer[0..dst_len];
    _ = Encoder.encode(dst, src);

    const src_len = try Decoder.calcSizeForSlice(dst);

    var decode_buffer: [1024]u8 = undefined;
    try Decoder.decode(decode_buffer[0..src_len], dst);

    const src_origin = decode_buffer[0..src_len];

    print("origin: {s}\n", .{src});
    print("base64 encoded: {s}\n", .{dst});
    print("back to origin: {s}\n", .{src_origin});
}
