const std = @import("std");
const zon = std.zon;

const Student = struct {
    name: []const u8,
    age: u16,
    favourites: []const []const u8,
};

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;

    const source = Student{
        .name = "John",
        .age = 20,
        .favourites = &.{ "swimming", "running" },
    };

    var writer = std.Io.Writer.Allocating.init(allocator);
    defer writer.deinit();
    try zon.stringify.serialize(source, .{}, &writer.writer);

    const expected =
        \\.{
        \\    .name = "John",
        \\    .age = 20,
        \\    .favourites = .{ "swimming", "running" },
        \\}
    ;
    const actual = writer.writer.buffered();
    try std.testing.expectEqualStrings(expected, actual);

    // Make it 0-sentinel
    try writer.writer.writeByte(0);
    const buffer = writer.writer.buffered();
    const input = buffer[0 .. buffer.len - 1 :0];

    var diag: zon.parse.Diagnostics = .{};
    defer diag.deinit(allocator);
    const parsed = zon.parse.fromSliceAlloc(
        Student,
        allocator,
        input,
        &diag,
        .{ .free_on_error = true },
    ) catch |err| {
        std.debug.print("Parse status: {any}\n", .{diag});
        return err;
    };
    defer zon.parse.free(allocator, parsed);

    try std.testing.expectEqualDeep(source, parsed);
}
