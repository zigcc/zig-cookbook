## Creating and adding complex numbers

Creates complex numbers of type [`std.math.Complex`]. Both the real and
imaginary part of the complex number must be of the same type.

Performing mathematical operations on complex numbers is the same as on
built in types: the numbers in question must be of the same type (i.e. floats
or integers).

```zig
const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const Complex = std.math.Complex;

pub fn main() !void {
    var complex_integer = Complex(i32).init(10, 20);
    var complex_integer2 = Complex(i32).init(5, 17);
    var complex_float = Complex(f32).init(10.1, 20.1);

    print("Complex integer: {}\n", .{complex_integer});
    print("Complex float: {}\n", .{complex_float});

    const sum = complex_integer.add(complex_integer2);

    try expectEqual(sum, Complex(i32).init(15, 37));
}
```

[`std.math.Complex`]: https://ziglang.org/documentation/0.11.0/std/#A;std:math.Complex
