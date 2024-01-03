const std = @import("std");

pub fn main() !void {
    var arr = [_]i32{ 1, 25, -4, 10, 100, 200, -100, -200 };
    var max_value: i32 = undefined;
    try findMax(&max_value, &arr);
    try std.testing.expectEqual(max_value, 200);
}

fn findMax(max_value: *i32, values: []i32) !void {
    const THRESHOLD: usize = 2;

    if (values.len <= THRESHOLD) {
        var res = values[0];
        for (values) |it| {
            res = @max(res, it);
        }
        max_value.* = res;
        return;
    }

    const mid = values.len / 2;
    const left = values[0..mid];
    const right = values[mid..];

    var left_max: i32 = undefined;
    const t1 = try std.Thread.spawn(.{}, findMax, .{ &left_max, left });
    var right_max: i32 = undefined;
    const t2 = try std.Thread.spawn(.{}, findMax, .{ &right_max, right });

    t1.join();
    t2.join();

    max_value.* = @max(left_max, right_max);
}
