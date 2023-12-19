## Creating complex numbers

Creates complex numbers of type [`std.math.Complex`]. Both the real and
imaginary part of the complex number must be of the same type.

```zig
const std = @import("std");
const print = std.debug.print;
const Complex = std.math.Complex;

pub fn main() !void {
    var complex_integer = Complex(i32).init(10, 20);
    var complex_float = Complex(f32).init(10.1, 20.1);

    print("Complex integer: {}\n", .{complex_integer});
    print("Complex float: {}\n", .{complex_float});
}
```

[`std.math.Complex`]: https://ziglang.org/documentation/0.11.0/std/#A;std:math.Complex


## Adding complex numbers

Performing mathematical operations on complex numbers is the same as on
built in types: the numbers in question must be of the same type (i.e. floats
or integers).

```zig
const std = @import("std");
const print = std.debug.print;
const Complex = std.math.Complex;

pub fn main() !void {
    var complex1 = Complex(i32).init(10, 20);
    var complex2 = Complex(i32).init(5, 17);

    const sum = complex1.add(complex2);

    print("Sum: {}\n", .{sum});
}
```
