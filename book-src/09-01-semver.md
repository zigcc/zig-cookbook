## Parse a version string.

Constructs a [`std.SemanticVersion`] from a string literal using [`SemanticVersion.parse`].

```zig
const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    const version = try std.SemanticVersion.parse("0.2.6");

    assert(version.order(.{
        .major = 0,
        .minor = 2,
        .patch = 6,
        .pre = null,
        .build = null,
    }) == .eq);
}
}
```

[`std.SemanticVersion`]: https://ziglang.org/documentation/0.11.0/std/#A;std:SemanticVersion
[`SemanticVersion.parse`]: https://ziglang.org/documentation/0.11.0/std/#A;std:SemanticVersion.parse

[Semantic Versioning Specification]: http://semver.org/
