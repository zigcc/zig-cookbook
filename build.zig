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
    const src_dir = try fs.cwd().openDir(b.path("assets/src").getPath(b), .{ .iterate = true });

    const target = b.standardTargetOptions(.{});
    var it = src_dir.iterate();
    const check = b.step("check", "Check if it compiles");

    LoopExample: while (try it.next()) |entry| {
        switch (entry.kind) {
            .file => {
                const name = std.mem.trimRight(u8, entry.name, ".zig");
                const exe = b.addExecutable(.{
                    .name = try allocPrint(b.allocator, "examples-{s}", .{name}),
                    .root_module = b.createModule(.{
                        .root_source_file = b.path(try allocPrint(b.allocator, "assets/src/{s}.zig", .{name})),
                        .target = target,
                        .optimize = .Debug,
                    }),
                });
                check.dependOn(&exe.step);
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
                    const lib = b.addLibrary(.{
                        .name = "regex_slim",
                        .root_module = b.createModule(.{
                            .target = target,
                            .optimize = .Debug,
                        }),
                        .linkage = .static,
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

                // Those examples won't stop so we don't add them to run_all step.
                const skip_list = [_][]const u8{
                    "04-01", // start tcp server
                    "04-02", // client of tcp server
                    "04-03", // udp listener
                    "05-03", // http server
                };
                for (skip_list) |example| {
                    if (std.mem.eql(u8, example, name)) {
                        continue :LoopExample;
                    }
                }
                run_all.dependOn(run_step);
            },
            else => {},
        }
    }
}
