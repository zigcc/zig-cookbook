# Bitfield

The fields of a `packed struct` are always laid out in memory in the order they are written, with no padding, so they are very nice to represent bitfield.

Boolean values are represented as 1 bit in packed struct, Zig also has arbitrary bit-width integers, like u28, u1 and so on.

```zig
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
```

## Reference
- [Packed structs in Zig make bit/flag sets trivial | Hexops' devlog](https://devlog.hexops.com/2022/packed-structs-in-zig/)
- [A Better Way to Implement Bit Fields](https://andrewkelley.me/post/a-better-way-to-implement-bit-fields.html)
