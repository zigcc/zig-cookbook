const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const rand = std.crypto.random;

    print("Random u8: {}\n", .{rand.int(u8)});
    print("Random u8 less than 10: {}\n", .{rand.uintLessThan(u8, 10)});
    print("Random u16: {}\n", .{rand.int(u16)});
    print("Random u32: {}\n", .{rand.int(u32)});
    print("Random i32: {}\n", .{rand.int(i32)});
    print("Random float: {d}\n", .{rand.float(f64)});

    var i: usize = 0;
    while (i < 9) {
        print("Random enum: {}\n", .{rand.enumValue(enum { red, green, blue })});
        i += 1;
    }
}
