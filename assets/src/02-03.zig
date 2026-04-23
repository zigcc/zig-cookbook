const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const password = "happy";

    //Random salt (Must be at least 8 bytes, recommended 16+)
    var raw: [8]u8 = undefined;
    try std.Io.randomSecure(io, &raw);
    const salt = try std.fmt.allocPrint(gpa, "{s}", .{std.fmt.bytesToHex(raw, .lower)});
    defer gpa.free(salt);

    //Parameters for Argon2id
    const params = std.crypto.pwhash.argon2.Params{
        .t = 3, // Iterations (time cost)
        .m = 16, // Memory cost in KiB (here 16 MiB)
        .p = 1, // Threads
    };

    const dk_len: usize = 16; // derive 16 or 32-byte key
    var derived: [dk_len]u8 = undefined;

    try std.crypto.pwhash.argon2.kdf(
        gpa,
        &derived,
        password,
        salt,
        params,
        .argon2id, //argon2i, argon2d and argon2id
        io,
    );

    std.debug.print("Argon2id derived key: {s}\n", .{std.fmt.bytesToHex(derived, .lower)});
}
