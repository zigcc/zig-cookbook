const std = @import("std");

const Ansi = struct {
    pub const reset = "\x1b[0m";
    pub const bold = "\x1b[1m";
    pub const dim = "\x1b[2m";
    pub const underline = "\x1b[4m";
    pub const inverse = "\x1b[7m";

    pub const black = "\x1b[30m";
    pub const red = "\x1b[31m";
    pub const green = "\x1b[32m";
    pub const yellow = "\x1b[33m";
    pub const blue = "\x1b[34m";
    pub const magenta = "\x1b[35m";
    pub const cyan = "\x1b[36m";
    pub const white = "\x1b[37m";

    pub const clear_screen = "\x1b[2J\x1b[H";
    pub const clear_line = "\x1b[2K";
    pub const hide_cursor = "\x1b[?25l";
    pub const show_cursor = "\x1b[?25h";

    pub fn print(style: []const u8, message: []const u8) void {
        std.debug.print("{s}{s}{s}\n", .{ style, message, reset });
    }

    pub fn moveCursor(row: u32, column: u32) void {
        std.debug.print("\x1b[{d};{d}H", .{ row, column });
    }
};

pub fn main() void {
    Ansi.print(Ansi.bold ++ Ansi.green, "Success");
    Ansi.print(Ansi.bold ++ Ansi.yellow, "Warning");
    Ansi.print(Ansi.bold ++ Ansi.red, "Error");
    Ansi.print(Ansi.dim ++ Ansi.cyan, "Dimmed informational text");

    std.debug.print("{s}Cursor control is also available.{s}\n", .{
        Ansi.underline,
        Ansi.reset,
    });
}
