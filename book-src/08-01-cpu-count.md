## Check number of logical cpu cores

Shows the number of logical CPU cores in current machine using [`std.Thread.getCpuCount`].

```zig
const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("Number of logical cores is {}\n", .{try std.Thread.getCpuCount()});
}
```

[`std.Thread.getCpuCount`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread.getCpuCount
