## Calculate the SHA-256 digest of a file

Writes some data to a file, then calculates the SHA-256 [`std.crypto.sha.sha2.Sha256`] of
the file's contents using [`Sha256`].

```zig,0.11.0
const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const Sha256 = std.crypto.hash.sha2.Sha256;

fn sha256_digest(reader: fs.File.Reader) ![32]u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var hash = Sha256.init(.{});
    while (try reader.readUntilDelimiterOrEofAlloc(alloc, '\n', 4096)) |line| {
        defer alloc.free(line);
        hash.update(line);
    }

    var out: [32]u8 = undefined;
    hash.final(out[0..]);
    return out;
}

pub fn main() !void {
    const path = "file.txt";
    const file = try fs.cwd().createFile(path, .{});
    errdefer file.close();

    try file.writeAll("We will generate a digest of this text");
    file.close();

    const f = try fs.cwd().openFile(path, .{});
    defer f.close();

    const digest = try sha256_digest(f.reader());

    print("SHA-256 digest is {s}", .{std.fmt.fmtSliceHexLower(&digest)});
}
```
