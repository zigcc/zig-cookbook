const std = @import("std");
const print = std.debug.print;
const zigcli = @import("zigcli");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const opt = try zigcli.structargs.parse(gpa, io, init.minimal.args, struct {
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
    }, .{ .argument_prompt = "[file]" });
    defer opt.deinit();

    const sep = "-" ** 30;
    print("{s}Program{s}\n{s}\n\n", .{ sep, sep, opt.program_name });
    print("{s}Arguments{s}\n", .{ sep, sep });
    inline for (std.meta.fields(@TypeOf(opt.options))) |fld| {
        const format = "{s:>10}: " ++ switch (fld.type) {
            []const u8 => "{s}",
            ?[]const u8 => "{?s}",
            else => "{any}",
        } ++ "\n";
        print(format, .{ fld.name, @field(opt.options, fld.name) });
    }

    print("\n{s}Positionals{s}\n", .{ sep, sep });
    for (opt.positional_arguments, 0..) |arg, idx| {
        print("{d}: {s}\n", .{ idx + 1, arg });
    }

    // Provide a print_help util method
    print("\n{s}print_help{s}\n", .{ sep, sep });
    const stdout = std.Io.File.stdout();
    var buf: [1024]u8 = undefined;
    var writer = stdout.writer(io, &buf);
    try opt.printHelp(&writer.interface);
}
