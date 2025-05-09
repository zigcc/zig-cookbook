const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const allocator = gpa.allocator();

    const cpu_count = try std.Thread.getCpuCount();

    var pool: std.Thread.Pool = undefined;
    try pool.init(.{
        .allocator = allocator,
        .n_jobs = cpu_count,
    });
    defer pool.deinit();

    var wg: std.Thread.WaitGroup = .{};
    for (0..cpu_count) |i| {
        pool.spawnWg(&wg, struct {
            fn run(id: usize) void {
                print("I'm from {d}\n", .{id});
            }
        }.run, .{i});
    }
    wg.wait();

    print("All threads exit.\n", .{});
}
