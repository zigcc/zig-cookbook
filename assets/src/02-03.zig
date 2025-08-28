const std = @import("std");
const testing = std.testing;

pub fn main() !void {
    var dbg = std.heap.DebugAllocator(.{}){};
    defer _ = dbg.deinit();
    const allocator = dbg.allocator();

    const password = "happy";
    const salt = "salt1234"; // Must be at least 8 bytes, recommended 16+

    // Parameters for Argon2id
    const params = std.crypto.pwhash.argon2.Params{
        .t = 3, // Iterations (time cost)
        .m = 16, // Memory cost in KiB (here 16 MiB)
        .p = 1, // Threads
    };

    const dk_len: usize = 16; // derive 16 or 32-byte key
    var derived: [dk_len]u8 = undefined;

    try std.crypto.pwhash.argon2.kdf(
        allocator,
        &derived,
        password,
        salt,
        params,
        .argon2id, //argon2i, argon2d and argon2id
    );
    const hex_digest = try std.fmt.allocPrint(allocator, "{s}", .{std.fmt.bytesToHex(derived, .lower)});
    defer allocator.free(hex_digest);

    try testing.expectEqualStrings("84594570e92044a3546416ec973b8f7f", hex_digest);
}
