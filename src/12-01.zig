const std = @import("std");
const print = std.debug.print;

const ColorFlags = packed struct(u32) {
    red: bool = false,
    green: bool = false,
    blue: bool = false,

    _padding: u29 = 0,
};

pub fn main() !void {
    const flag_a: ColorFlags = @bitCast(@as(u32, 0xFF));

    if (flag_a.red) {
        print("flag_a contains red\n", .{});
    }

    if (flag_a.red and flag_a.green) {
        print("flag_a contains red and green\n", .{});
    }

    const flag_b: ColorFlags = @bitCast(@as(u32, 0x01));

    if (flag_b.red) {
        print("flag_b contains red\n", .{});
    }

    if (flag_b.red and flag_b.green) {
        print("flag_b contains red and green\n", .{});
    }
}
