## Creating and adding complex numbers

Creates complex numbers of type [`std.math.Complex`]. Both the real and
imaginary part of the complex number must be of the same type.

Performing mathematical operations on complex numbers is the same as on
built in types: the numbers in question must be of the same type (i.e. floats
or integers).

```zig
{{#include ../src/11-01.zig }}
```

[`std.math.complex`]: https://ziglang.org/documentation/0.11.0/std/#A;std:math.Complex
