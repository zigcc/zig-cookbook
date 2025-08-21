const std = @import("std");
const fs = std.fs;
const Sha256 = std.crypto.hash.sha2.Sha256;

// In real world, this may set to page_size, usually it's 4096.
const BUF_SIZE = 16;

fn sha256_digest(
    file: fs.File,
) ![Sha256.digest_length]u8 {
    var sha256 = Sha256.init(.{});
    const rdr = file.reader();

    var buf: [BUF_SIZE]u8 = undefined;
    var n = try rdr.read(&buf);
    while (n != 0) {
        sha256.update(buf[0..n]);
        n = try rdr.read(&buf);
    }

    return sha256.finalResult();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("tests/zig-zen.txt", .{});
    defer file.close();

    const digest = try sha256_digest(file);
    const hex_digest = try std.fmt.allocPrint(
        allocator,
        "{s}",
        .{std.fmt.fmtSliceHexLower(&digest)},
    );
    defer allocator.free(hex_digest);

    try std.testing.expectEqualStrings(
        "2210e9263ece534df0beff39ec06850d127dc60aa17bbc7769c5dc2ea5f3e342",
        hex_digest,
    );
}
