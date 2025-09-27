const std = @import("std");
const json = std.json;
const testing = std.testing;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Deserialize JSON
    const json_str =
        \\{
        \\  "userid": 103609,
        \\  "verified": true,
        \\  "access_privileges": [
        \\    "user",
        \\    "admin"
        \\  ]
        \\}
    ;
    const T = struct { userid: i32, verified: bool, access_privileges: [][]u8 };
    const parsed = try json.parseFromSlice(T, allocator, json_str, .{});
    defer parsed.deinit();

    var value = parsed.value;

    try testing.expect(value.userid == 103609);
    try testing.expect(value.verified);
    try testing.expectEqualStrings("user", value.access_privileges[0]);
    try testing.expectEqualStrings("admin", value.access_privileges[1]);

    // Serialize JSON
    value.verified = false;
    var out = std.Io.Writer.Allocating.init(allocator);
    defer out.deinit();
    var stringifier = json.Stringify{
        .writer = &out.writer,
        .options = .{
            .whitespace = .indent_2,
        },
    };
    try stringifier.write(value);

    try testing.expectEqualStrings(
        \\{
        \\  "userid": 103609,
        \\  "verified": false,
        \\  "access_privileges": [
        \\    "user",
        \\    "admin"
        \\  ]
        \\}
    , out.writer.buffered());
}
