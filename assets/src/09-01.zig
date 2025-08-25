const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    const version = try std.SemanticVersion.parse("0.2.6");

    assert(version.order(.{
        .major = 0,
        .minor = 2,
        .patch = 6,
        .pre = null,
        .build = null,
    }) == .eq);
}
