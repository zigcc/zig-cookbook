# Bitfield

The fields of a [packed struct](https://ziglang.org/documentation/master/#packed-struct) are always laid out in memory in the order they are written, with no padding, so they are very nice to represent bitfield.

Boolean values are represented as 1 bit in packed struct, Zig also has arbitrary bit-width integers, like u28, u1 and so on.

```zig
{{#include ../src/12-01.zig }}
```

## Reference

- [Packed structs in Zig make bit/flag sets trivial | Hexops' devlog](https://devlog.hexops.com/2022/packed-structs-in-zig/)
- [A Better Way to Implement Bit Fields](https://andrewkelley.me/post/a-better-way-to-implement-bit-fields.html)
