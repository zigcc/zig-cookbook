//! Get random bytes through the Io context.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var random_bytes: [8]u8 = undefined;
    try std.Io.randomSecure(init.io, &random_bytes);

    std.debug.print("secure random bytes: {x}\n", .{random_bytes});
}
