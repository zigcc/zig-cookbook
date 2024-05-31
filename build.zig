const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;
const allocPrint = std.fmt.allocPrint;
const print = std.debug.print;

pub fn build(b: *std.Build) !void {
    const run_all_step = b.step("run-all", "Run all examples");
    try addExample(b, run_all_step);
}

fn addExample(b: *std.Build, run_all: *std.Build.Step) !void {
    const is_latest_zig = builtin.zig_version.minor > 12;
    const src_dir = try fs.cwd().openDir("src", .{ .iterate = true });

    const target = b.standardTargetOptions(.{});
    var it = src_dir.iterate();
    while (try it.next()) |entry| {
        switch (entry.kind) {
            .file => {
                const name = std.mem.trimRight(u8, entry.name, ".zig");
                const exe = b.addExecutable(.{
                    .name = try allocPrint(b.allocator, "examples-{s}", .{name}),
                    .root_source_file = b.path(try allocPrint(b.allocator, "src/{s}.zig", .{name})),
                    .target = target,
                    .optimize = .Debug,
                });
                var opts = b.addOptions();
                opts.addOption(bool, "is_latest_zig", is_latest_zig);
                exe.root_module.addOptions("build-info", opts);
                if (std.mem.eql(u8, "13-01", name)) {
                    const zigcli = b.dependency("zigcli", .{});
                    exe.root_module.addImport("simargs", zigcli.module("simargs"));
                } else if (std.mem.eql(u8, "14-01", name)) {
                    exe.linkSystemLibrary("sqlite3");
                    exe.linkLibC();
                } else if (std.mem.eql(u8, "14-02", name)) {
                    exe.linkSystemLibrary("libpq");
                    exe.linkLibC();
                } else if (std.mem.eql(u8, "14-03", name)) {
                    exe.linkSystemLibrary("mysqlclient");
                    exe.linkLibC();
                } else if (std.mem.eql(u8, "15-01", name)) {
                    const lib = b.addStaticLibrary(.{
                        .name = "regex_slim",
                        .optimize = .Debug,
                        .target = target,
                    });

                    lib.addCSourceFiles(.{
                        .files = &.{"lib/regex_slim.c"},
                        .flags = &.{"-std=c99"},
                    });
                    lib.linkLibC();
                    exe.linkLibrary(lib);
                    exe.addIncludePath(b.path("lib"));
                    exe.linkLibC();
                }

                b.installArtifact(exe);
                const run_cmd = b.addRunArtifact(exe);
                if (b.args) |args| {
                    run_cmd.addArgs(args);
                }
                const run_step = &run_cmd.step;
                b.step(try allocPrint(b.allocator, "run-{s}", .{name}), try allocPrint(
                    b.allocator,
                    "Run example {s}",
                    .{name},
                )).dependOn(run_step);

                // 04-01 start tcp server, and won't stop so we skip it here
                // 04-02 is the server's client.
                // 04-03 starts udp listener.
                if (std.mem.eql(u8, "04-01", name) or
                    std.mem.eql(u8, "04-02", name) or
                    std.mem.eql(u8, "04-03", name))
                {
                    continue;
                }
                run_all.dependOn(run_step);
            },
            else => {},
        }
    }
}
