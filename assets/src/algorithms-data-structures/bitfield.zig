const std = @import("std");
const print = std.debug.print;

const ColorFlags = packed struct(u32) {
    red: bool = false,
    green: bool = false,
    blue: bool = false,

    _padding: u29 = 0,
};

pub fn main() !void {
    const tom: ColorFlags = @bitCast(@as(u32, 0xFF));

    if (tom.red) {
        print("Tom likes red.\n", .{});
    }

    if (tom.red and tom.green) {
        print("Tom likes red and green.\n", .{});
    }

    const jerry: ColorFlags = @bitCast(@as(u32, 0x01));

    if (jerry.red) {
        print("Jerry likes red.\n", .{});
    }

    if (jerry.red and !jerry.green) {
        print("Jerry likes red, not green.\n", .{});
    }
}
