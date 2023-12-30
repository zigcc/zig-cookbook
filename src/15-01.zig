const std = @import("std");
const c = @cImport({
    @cInclude("regex.h");
});
pub fn main() !void {
    var my_re: c.regex_t = undefined;
    if (0 != c.regcomp(&my_re, "[ab]c", c.REG_EXTENDED)) {
        return error.compile;
    }

    std.debug.print("{any}\n", .{my_re});
}
