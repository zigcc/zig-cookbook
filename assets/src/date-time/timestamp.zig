//! Demonstrate Unix timestamps and UTC date/time calculation in Zig.

const std = @import("std");
const Io = std.Io;
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // 1. Wall-clock time is retrieved via Io.Clock.real.
    const now = Io.Clock.real.now(io);
    const now_secs = now.toSeconds();
    const now_millis = now.toMilliseconds();
    const now_nanos = now.toNanoseconds();

    print("Current Unix timestamp (seconds): {d}\n", .{now_secs});
    print("Current Unix timestamp (milliseconds): {d}\n", .{now_millis});
    print("Current Unix timestamp (nanoseconds): {d}\n", .{now_nanos});

    // 2. Break down current Unix timestamp into UTC date and time components.
    const epoch_seconds: std.time.epoch.EpochSeconds = .{ .secs = @intCast(now_secs) };
    const epoch_day = epoch_seconds.getEpochDay();
    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    const day_seconds = epoch_seconds.getDaySeconds();

    print("Current UTC Date & Time: {d:0>4}-{d:0>2}-{d:0>2} {d:0>2}:{d:0>2}:{d:0>2}\n", .{
        year_day.year,
        month_day.month.numeric(),
        month_day.day_index + 1, // day_index is 0-indexed
        day_seconds.getHoursIntoDay(),
        day_seconds.getMinutesIntoHour(),
        day_seconds.getSecondsIntoMinute(),
    });

    // 3. Verification with a fixed timestamp: 2025-01-01 00:00:00 UTC (1735689600)
    const fixed_secs: u64 = 1735689600;
    const fixed_epoch: std.time.epoch.EpochSeconds = .{ .secs = fixed_secs };
    const fixed_year_day = fixed_epoch.getEpochDay().calculateYearDay();
    const fixed_month_day = fixed_year_day.calculateMonthDay();
    const fixed_day_seconds = fixed_epoch.getDaySeconds();

    try std.testing.expectEqual(2025, fixed_year_day.year);
    try std.testing.expectEqual(@as(u8, 1), fixed_month_day.month.numeric());
    try std.testing.expectEqual(0, fixed_month_day.day_index);
    try std.testing.expectEqual(0, fixed_day_seconds.getHoursIntoDay());
    try std.testing.expectEqual(0, fixed_day_seconds.getMinutesIntoHour());
    try std.testing.expectEqual(0, fixed_day_seconds.getSecondsIntoMinute());
}
