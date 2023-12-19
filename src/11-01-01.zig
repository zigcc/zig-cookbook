const std = @import("std");
const print = std.debug.print;
const Complex = std.math.Complex;

pub fn main() !void {
    var complex_integer = Complex(i32).init(10, 20);
    var complex_float = Complex(f32).init(10.1, 20.1);

    print("Complex integer: {}\n", .{complex_integer});
    print("Complex float: {}\n", .{complex_float});
}
