//! Use the process and terminal-facing parts of std.Io.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    const stdout = std.Io.File.stdout();

    const current_path = try std.process.currentPathAlloc(io, gpa);
    defer gpa.free(current_path);
    const executable_path = try std.process.executablePathAlloc(io, gpa);
    defer gpa.free(executable_path);

    const is_tty = try stdout.isTty(io);
    const supports_color = try stdout.supportsAnsiEscapeCodes(io);

    var writer_buffer: [512]u8 = undefined;
    var writer = stdout.writer(io, &writer_buffer);
    try writer.interface.print("current path: {s}\n", .{current_path});
    try writer.interface.print("executable: {s}\n", .{executable_path});
    try writer.interface.print("stdout is tty: {any}\n", .{is_tty});
    try writer.interface.print("ANSI supported: {any}\n", .{supports_color});
    try writer.interface.flush();
}
