const std = @import("std");
const c = @cImport({
    @cInclude("regex.h");
    @cInclude("regex_slim.h");
});

const Regex = struct {
    inner: *c.regex_t,
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator) !Regex {
        var slice = try allocator.alignedAlloc(u8, c.alignof_regex_t, c.sizeof_regex_t);

        return .{
            .inner = @as(*c.regex_t, @ptrCast(slice.ptr)),
            .allocator = allocator,
        };
    }

    fn deinit(self: Regex) void {
        const ptr: [*]align(c.alignof_regex_t) u8 = @alignCast(@as([*]u8, @ptrCast(self.inner)));
        self.allocator.free(ptr[0..c.sizeof_regex_t]);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const my_re = try Regex.init(allocator);
    defer my_re.deinit();

    if (0 != c.regcomp(my_re.inner, "[ab]c", c.REG_EXTENDED)) {
        return error.compile;
    }

    std.debug.print("{any}\n", .{my_re});
}
