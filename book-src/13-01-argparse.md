# Argument Parsing

Parse arguments is common in command line programs and there are some packages in Zig help you ease the task, to name a few:
- [Hejsil/zig-clap](https://github.com/Hejsil/zig-clap)
- [MasterQ32/zig-args](https://github.com/MasterQ32/zig-args/)
- [Zigcli](https://zigcli.liujiacai.net/)

Here we will give an example using [zigcli](https://github.com/jiacai2050/zigcli).
```zig
const std = @import("std");
const simargs = @import("simargs");
const print = std.debug.print;

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
    for (opt.positional_args.items, 0..) |arg, idx| {
        print("{d}: {s}\n", .{ idx + 1, arg });
    }

    // Provide a print_help util method
    print("\n{s}print_help{s}\n", .{ sep, sep });
    const stdout = std.io.getStdOut();
    try opt.print_help(stdout.writer());
}
```
