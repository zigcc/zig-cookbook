const std = @import("std");
const print = std.debug.print;
const crypto = std.crypto;
const HmacSha256 = crypto.auth.hmac.sha2.HmacSha256;

pub fn main() !void {
    const salt = [_]u8{ 'a', 'b', 'c' };
    const password = "Guess Me If You Can!";
    const rounds = 1_000;

    // Usually 16 or 32 bytes
    var derived_key: [16]u8 = undefined;
    try crypto.pwhash.pbkdf2(&derived_key, password, &salt, rounds, HmacSha256);

    try std.testing.expectEqualSlices(
        u8,
        &[_]u8{
            44,
            184,
            223,
            181,
            238,
            128,
            211,
            50,
            149,
            114,
            26,
            86,
            225,
            172,
            116,
            81,
        },
        &derived_key,
    );
}
