const std = @import("std");

pub fn main() !void {
    var dbg = std.heap.DebugAllocator(.{}){};
    defer _ = dbg.deinit();
    const allocator = dbg.allocator();

    const password = "happy";

    //Random salt (Must be at least 8 bytes, recommended 16+)
    var raw: [8]u8 = undefined;
    std.crypto.random.bytes(&raw);
    const salt = try std.fmt.allocPrint(allocator, "{s}", .{std.fmt.bytesToHex(raw, .lower)});
    defer allocator.free(salt);

    //Parameters for Argon2id
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

    std.debug.print("Argon2id derived key: {s}\n", .{std.fmt.bytesToHex(derived, .lower)});
}