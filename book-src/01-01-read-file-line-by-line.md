# Read file line by line

There is a [Reader] type in Zig, which provides various methods to read file, such as `readAll`, `readInt`, here we will use `streamUntilDelimiter` to split lines.

```zig
const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("tests/zig-zen.txt", .{});
    defer file.close();

    var rdr = blk: {
        // Usually buffered reader is faster, so we use one here.
        var buf_reader = std.io.bufferedReader(file.reader());
        break :blk buf_reader.reader();
    };
    var line_no: usize = 0;

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();
    var wtr = line.writer();
    while (true) {
        // Clear the line so we can reuse it.
        defer line.clearRetainingCapacity();

        rdr.streamUntilDelimiter(wtr, '\n', 4096) catch |err| switch (err) {
            error.EndOfStream => return,
            else => return err,
        };
        line_no += 1;
        print("{d}--{s}\n", .{ line_no, line.items });
    }
}
```

[Reader]: https://ziglang.org/documentation/0.11.0/std/#A;std:io.Reader
