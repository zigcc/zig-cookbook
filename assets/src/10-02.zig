const std = @import("std");
const zon = std.zon;
const Allocator = std.mem.Allocator;

const Student = struct {
    name: []const u8,
    age: u16,
    favourites: []const []const u8,

    fn deinit(self: *Student, allocator: Allocator) void {
        allocator.free(self.name);
        for (self.favourites) |item| {
            allocator.free(item);
        }
        allocator.free(self.favourites);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const allocator = gpa.allocator();

    const source = Student{
        .name = "John",
        .age = 20,
        .favourites = &.{ "swimming", "running" },
    };

    var dst = std.ArrayList(u8).init(allocator);
    defer dst.deinit();
    try zon.stringify.serialize(source, .{}, dst.writer());

    const expected =
        \\.{
        \\    .name = "John",
        \\    .age = 20,
        \\    .favourites = .{ "swimming", "running" },
        \\}
    ;
    try std.testing.expectEqualStrings(expected, dst.items);

    // Make it 0-sentinel
    try dst.append(0);
    const input = dst.items[0 .. dst.items.len - 1 :0];

    var status: zon.parse.Status = .{};
    defer status.deinit(allocator);
    var parsed = zon.parse.fromSlice(
        Student,
        allocator,
        input,
        &status,
        .{ .free_on_error = true },
    ) catch |err| {
        std.debug.print("Parse status: {any}\n", .{status});
        return err;
    };
    defer parsed.deinit(allocator);

    try std.testing.expectEqualDeep(source, parsed);
}
