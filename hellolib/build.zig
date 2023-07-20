const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "helloworld",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // link with the standard library libcpp
    exe.linkLibCpp();
    exe.addIncludePath("src");
    exe.addCSourceFile("src/hello.cpp", &.{});

    b.installArtifact(exe);
}
