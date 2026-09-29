//! Submit low-level Io operations through a batch.

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const stdout = std.Io.File.stdout();
    const first_data = [_][]const u8{"batch operation one\n"};
    const second_data = [_][]const u8{"batch operation two\n"};

    var storage: [2]std.Io.Operation.Storage = undefined;
    var batch: std.Io.Batch = .init(&storage);
    defer batch.cancel(io);

    _ = batch.add(.{ .file_write_streaming = .{
        .file = stdout,
        .data = &first_data,
    } });
    _ = batch.add(.{ .file_write_streaming = .{
        .file = stdout,
        .data = &second_data,
    } });

    var completed_count: u32 = 0;
    while (completed_count < 2) {
        try batch.awaitAsync(io);
        while (batch.next()) |completion| {
            const bytes_written = try completion.result.file_write_streaming;
            std.debug.print("completed operation {d}: {d} bytes\n", .{
                completion.index,
                bytes_written,
            });
            completed_count += 1;
        }
    }
}
