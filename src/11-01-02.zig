const std = @import("std");
const print = std.debug.print;
const Complex = std.math.Complex;

pub fn main() !void {
    var complex1 = Complex(i32).init(10, 20);
    var complex2 = Complex(i32).init(5, 17);

    const sum = complex1.add(complex2);

    print("Sum: {}\n", .{sum});
}
