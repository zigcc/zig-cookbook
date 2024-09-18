# Regular Expressions

Currently there is no regex support in Zig, so the best way to go is binding with Posix's [regex.h](https://pubs.opengroup.org/onlinepubs/7908799/xsh/regex.h.html).

Interop with C is easy in Zig, but since translate-c doesn't support bitfields, we can't use `regex_t` directly. So here we create a [static C library](https://github.com/zigcc/zig-cookbook/blob/460dea1f2f9937ab512a70683aacab79e34c723a/build.zig#L50) first, providing two functions:

```c
regex_t* alloc_regex_t(void);
void free_regex_t(regex_t* ptr);
```

`regex_t*` is a pointer, it has fixed size, so we can use it directly in Zig.

```zig
{{#include ../src/15-01.zig }}
```

## References

- [regex(3) — Linux manual page](https://man7.org/linux/man-pages/man3/regex.3.html)
- [How to allocate a struct of incomplete type in Zig?](https://stackoverflow.com/a/73095054)
- [Regular Expressions in Zig](https://www.openmymind.net/Regular-Expressions-in-Zig/)
