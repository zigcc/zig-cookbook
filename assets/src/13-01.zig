const std = @import("std");
const print = std.debug.print;
const simargs = @import("simargs");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var opt = try simargs.parse(allocator, struct {
        // Those fields declare arguments options
        // only `output` is required, others are all optional
        verbose: ?bool,
        @"user-agent": enum { Chrome, Firefox, Safari } = .Firefox,
        timeout: ?u16 = 30, // default value
        output: []const u8 = "/tmp",
        help: bool = false,

        // This declares option's short name
        pub const __shorts__ = .{
            .verbose = .v,
            .output = .o,
            .@"user-agent" = .A,
            .help = .h,
        };

        // This declares option's help message
        pub const __messages__ = .{
            .verbose = "Make the operation more talkative",
            .output = "Write to file instead of stdout",
            .timeout = "Max time this request can cost",
        };
    }, "[file]", null);
    defer opt.deinit();

    const sep = "-" ** 30;
    print("{s}Program{s}\n{s}\n\n", .{ sep, sep, opt.program });
    print("{s}Arguments{s}\n", .{ sep, sep });
    inline for (std.meta.fields(@TypeOf(opt.args))) |fld| {
        const format = "{s:>10}: " ++ switch (fld.type) {
            []const u8 => "{s}",
            ?[]const u8 => "{?s}",
            else => "{any}",
        } ++ "\n";
        print(format, .{ fld.name, @field(opt.args, fld.name) });
    }

    print("\n{s}Positionals{s}\n", .{ sep, sep });
    for (opt.positional_args, 0..) |arg, idx| {
        print("{d}: {s}\n", .{ idx + 1, arg });
    }

    // Provide a print_help util method
    print("\n{s}print_help{s}\n", .{ sep, sep });
    const stdout = std.fs.File.stdout();
    var buf: [1024]u8 = undefined;
    var writer = stdout.writer(&buf);
    try opt.printHelp(&writer.interface);
}
