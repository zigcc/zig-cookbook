const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var arguments = init.minimal.args.iterate();
    _ = arguments.next();

    var verbose = false;
    var output: []const u8 = "stdout";
    var files: [8][]const u8 = undefined;
    var file_count: usize = 0;

    while (arguments.next()) |argument| {
        if (std.mem.eql(u8, argument, "--verbose")) {
            verbose = true;
        } else if (std.mem.eql(u8, argument, "--output")) {
            output = arguments.next() orelse return error.MissingOutput;
        } else {
            if (argument.len > 0) {
                if (argument[0] == '-') {
                    std.debug.print("unknown option: {s}\n", .{argument});
                    return error.UnknownOption;
                }
            }

            if (file_count == files.len) {
                return error.TooManyFiles;
            }

            files[file_count] = argument;
            file_count += 1;
        }
    }

    std.debug.print("verbose: {any}\n", .{verbose});
    std.debug.print("output: {s}\n", .{output});
    for (files[0..file_count]) |file| {
        std.debug.print("file: {s}\n", .{file});
    }
}
