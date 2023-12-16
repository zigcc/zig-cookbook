const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const rand = std.crypto.random;

    const n1: u8 = rand.int(u8);
    const n2: u16 = rand.int(u16);
    print("Random u8: {}\n", .{n1});
    print("Random u16: {}\n", .{n2});
    print("Random u32: {}\n", .{rand.int(u32)});
    print("Random i32: {}\n", .{rand.int(i32)});
    print("Random float: {d}\n", .{rand.float(f64)});
}
