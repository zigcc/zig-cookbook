const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const Complex = std.math.Complex;

pub fn main() !void {
    const complex_integer = Complex(i32).init(10, 20);
    const complex_integer2 = Complex(i32).init(5, 17);
    const complex_float = Complex(f32).init(10.1, 20.1);

    print("Complex integer: {}\n", .{complex_integer});
    print("Complex float: {}\n", .{complex_float});

    const sum = complex_integer.add(complex_integer2);

    try expectEqual(sum, Complex(i32).init(15, 37));
}
