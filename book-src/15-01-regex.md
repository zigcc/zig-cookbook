# Regex Expressions

Currently there is no regex support in Zig, so the best way to go is binding with Posix's [regex.h](https://pubs.opengroup.org/onlinepubs/7908799/xsh/regex.h.html).

Interop with C is easy in Zig, but since translate-c doesn't support bitfields, we can't use `regex_t` directly.

So here we create a static C library first, providing two functions:
```c
regex_t* alloc_regex_t(void);
void free_regex_t(regex_t* ptr);
```

`regex_t*` is a pointer, we can use it directly in Zig. The rest should be straightforward.

```zig
const std = @import("std");
const print = std.debug.print;
const c = @cImport({
    @cInclude("regex.h");
    // This is our static libray.
    @cInclude("regex_slim.h");
});

const Regex = struct {
    inner: *c.regex_t,

    fn init(pattern: [:0]const u8) !Regex {
        const inner = c.alloc_regex_t().?;
        if (0 != c.regcomp(inner, pattern, c.REG_NEWLINE | c.REG_EXTENDED)) {
            return error.compile;
        }

        return .{
            .inner = inner,
        };
    }

    fn deinit(self: Regex) void {
        c.free_regex_t(self.inner);
    }

    fn matches(self: Regex, input: [:0]const u8) bool {
        const match_size = 1;
        var pmatch: [match_size]c.regmatch_t = undefined;
        return 0 == c.regexec(self.inner, input, match_size, &pmatch, 0);
    }

    fn exec(self: Regex, input: [:0]const u8) !void {
        const match_size = 1;
        var pmatch: [match_size]c.regmatch_t = undefined;

        var i: usize = 0;
        var string = input;
        const expected = [_][]const u8{ "John Do", "John Foo" };
        while (true) {
            if (0 != c.regexec(self.inner, string, match_size, &pmatch, 0)) {
                break;
            }

            const slice = string[@as(usize, @intCast(pmatch[0].rm_so))..@as(usize, @intCast(pmatch[0].rm_eo))];

            try std.testing.expectEqualStrings(expected[i], slice);

            string = string[@intCast(pmatch[0].rm_eo)..];
            i += 1;
        }

        try std.testing.expectEqual(i, 2);
    }
};

pub fn main() !void {
    {
        const regex = try Regex.init("[ab]c");
        defer regex.deinit();

        try std.testing.expect(regex.matches("bc"));
        try std.testing.expect(!regex.matches("cc"));
    }

    {
        const regex = try Regex.init("John.*o");
        defer regex.deinit();

        try regex.exec(
            \\ 1) John Driverhacker;
            \\ 2) John Doe;
            \\ 3) John Foo;
            \\
        );
    }
}

```

## References
- [regex(3) — Linux manual page](https://man7.org/linux/man-pages/man3/regex.3.html)
- [How to allocate a struct of incomplete type in Zig?](https://stackoverflow.com/a/73095054)
- [Regular Expressions in Zig](https://www.openmymind.net/Regular-Expressions-in-Zig/)
