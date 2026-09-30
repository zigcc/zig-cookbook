const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const argv = [_][]const u8{
        "echo",
        "-n",
        "hello",
        "world",
    };

    // `std.process.run` spawns the child, collects stdout/stderr into owned
    // slices, and waits for it to exit. Use `SpawnOptions` + `std.process.spawn`
    // directly for more control.
    const result = try std.process.run(gpa, io, .{
        .argv = &argv,
    });
    defer gpa.free(result.stdout);
    defer gpa.free(result.stderr);

    try std.testing.expectEqual(@as(u8, 0), result.term.exited);
    try std.testing.expectEqualStrings("hello world", result.stdout);
    try std.testing.expectEqualStrings("", result.stderr);
}
