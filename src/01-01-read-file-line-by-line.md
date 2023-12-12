# Read file line by line

There is a Reader type in Zig, which provides various methods to read file.

```zig
    const file = try fs.cwd().openFile("build.zig", .{});
    defer file.close();

    const rdr = file.reader();
    var line_no: usize = 0;
    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        defer allocator.free(line);

        line_no += 1;
        print("{d}--{s}\n", .{ line_no, line });
    }
```
