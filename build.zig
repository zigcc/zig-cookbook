const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;
const allocPrint = std.fmt.allocPrint;
const print = std.debug.print;

pub fn build(b: *std.Build) !void {
    const run_all_step = b.step("run-all", "Run all examples");
    try addExample(b, run_all_step);
}

fn addExample(b: *std.Build, run_all: *std.build.Step) !void {
    const gt_zig_0_11 = builtin.zig_version.minor > 11;
    const src_dir = if (gt_zig_0_11)
        try fs.cwd().openDir("src", .{ .iterate = true })
    else
        try fs.cwd().openIterableDir("src", .{});

    var it = src_dir.iterate();
    while (try it.next()) |entry| {
        switch (entry.kind) {
            .file => {
                const name = std.mem.trimRight(u8, entry.name, ".zig");
                if (!gt_zig_0_11) {
                    // Those require zig master to run.
                    if (std.mem.eql(u8, "13-01", name)) {
                        continue;
                    }
                }

                const exe = b.addExecutable(.{
                    .name = try allocPrint(b.allocator, "examples-{s}", .{name}),
                    .root_source_file = .{ .path = try allocPrint(b.allocator, "src/{s}.zig", .{name}) },
                    .target = .{},
                    .optimize = .Debug,
                });
                if (std.mem.eql(u8, "13-01", name)) {
                    const zigcli = b.dependency("zigcli", .{});
                    exe.addModule("simargs", zigcli.module("simargs"));
                } else if (std.mem.eql(u8, "14-01", name)) {
                    exe.linkSystemLibrary("sqlite3");
                    exe.linkLibC();
                    // const sqlite = b.dependency("sqlite", .{});
                    // exe.addModule("sqlite", sqlite.module("sqlite"));
                    // exe.linkLibrary(sqlite.artifact("sqlite"));
                } else if (std.mem.eql(u8, "14-02", name)) {
                    exe.linkSystemLibrary("libpq");
                    exe.linkLibC();
                }

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
                if (std.mem.eql(u8, "04-01", name) or std.mem.eql(u8, "04-02", name)) {
                    continue;
                }
                run_all.dependOn(run_step);
            },
            else => {},
        }
    }
}
