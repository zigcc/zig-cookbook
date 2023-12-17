const std = @import("std");
const print = std.debug.print;
const crypto = std.crypto;
const HmacSha256 = crypto.auth.hmac.sha2.HmacSha256;

pub fn main() !void {
    var prng = std.rand.DefaultPrng.init(@intCast(std.time.timestamp()));
    const rand = prng.random();

    var salt: [64]u8 = undefined;
    rand.bytes(&salt);

    const password = "Guess Me If You Can!";
    const rounds = 100_000;
    const dk_len = 64;

    var dk: [dk_len]u8 = undefined;
    try crypto.pwhash.pbkdf2(&dk, password, &salt, rounds, HmacSha256);

    print("Salt: {}\n", .{std.fmt.fmtSliceHexUpper(&salt)});
    print("PBKDF2 hash: {}\n", .{std.fmt.fmtSliceHexUpper(&dk)});
}
