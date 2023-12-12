const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const Sha256 = std.crypto.hash.sha2.Sha256;

fn sha256_digest(
    allocator: std.mem.Allocator,
    file: fs.File,
) ![Sha256.digest_length]u8 {
    const md = try file.metadata();
    const size = md.size();
    const bytes = try file.reader().readAllAlloc(allocator, size);
    defer allocator.free(bytes);

    var out: [Sha256.digest_length]u8 = undefined;
    Sha256.hash(bytes, &out, .{});
    return out;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("build.zig", .{});
    defer file.close();

    const digest = try sha256_digest(allocator, file);
    print("SHA-256 digest is {s}", .{std.fmt.fmtSliceHexLower(&digest)});
}
