# Mmap file

Creates a memory map of a file using mmap and simulates some non-sequential reads from the file. Using a memory map means you just index into a slice rather than dealing with seek to navigate a File.

```zig
    const file = try fs.cwd().createFile(filename, .{
        .read = true,
        .truncate = true,
        .exclusive = false, // Set to true will ensure this file is created by us
    });
    defer file.close();

    // Before mmap, we need to ensure file isn't empty
    try file.setEndPos(file_size);

    const md = try file.metadata();
    print("File size: {d}\n", .{md.size()});

    var ptr = try std.os.mmap(
        null,
        20,
        std.os.PROT.READ | std.os.PROT.WRITE,
        std.os.MAP.PRIVATE,
        file.handle,
        0,
    );
    defer std.os.munmap(ptr);

    // Write file via mmap
    std.mem.copyForwards(u8, ptr, "hello zig cookbook");

    // Read file via mmap
    print("File body: {s}", .{ptr});

```
