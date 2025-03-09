const std = @import("std");
const print = std.debug.print;
const Child = std.process.Child;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const allocator = gpa.allocator();

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

    var stdout: std.ArrayListUnmanaged(u8) = .empty;
    defer stdout.deinit(allocator);
    var stderr: std.ArrayListUnmanaged(u8) = .empty;
    defer stderr.deinit(allocator);

    try child.spawn();
    try child.collectOutput(allocator, &stdout, &stderr, 1024);
    const term = try child.wait();

    try std.testing.expectEqual(term.Exited, 0);
    try std.testing.expectEqualStrings("hello world", stdout.items);
    try std.testing.expectEqualStrings("", stderr.items);
}
