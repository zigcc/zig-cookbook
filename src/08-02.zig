const std = @import("std");
const print = std.debug.print;
const Child = std.process.Child;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const argv = [_][]const u8{
        "echo",
        "-n",
        "hello",
        "world",
    };

    // By default, child will inherit stdout & stderr from its parents,
    // this usually means that child's output will be printed to terminal.
    // Here we change them to pipe and collect into `ArrayList`.
    var child = Child.init(&argv, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    var stdout = ArrayList(u8).init(allocator);
    var stderr = ArrayList(u8).init(allocator);
    defer {
        stdout.deinit();
        stderr.deinit();
    }

    try child.spawn();
    try child.collectOutput(&stdout, &stderr, 1024);
    const term = try child.wait();

    try std.testing.expectEqual(term.Exited, 0);
    try std.testing.expectEqualStrings("hello world", stdout.items);
    try std.testing.expectEqualStrings("", stderr.items);
}
