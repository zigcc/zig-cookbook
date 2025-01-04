const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var pool: std.Thread.Pool = undefined;
    try pool.init(.{
        .allocator = allocator,
        .n_jobs = 4,
    });
    defer pool.deinit();

    var wg: std.Thread.WaitGroup = .{};
    for (0..10) |i| {
        pool.spawnWg(&wg, struct {
            fn run(id: usize) void {
                print("I'm from {d}\n", .{id});
            }
        }.run, .{i});
    }
    wg.wait();

    print("All threads exit.\n", .{});
}
