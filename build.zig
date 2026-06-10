const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // C Libraries
    const glad_c = b.addTranslateC(.{
        .root_source_file = b.path("thirdparty/glad/glad.c"),
        .target = target,
        .optimize = optimize,
    });
    glad_c.addIncludePath(b.path("thirdparty/glad/include"));

    const khr_c = b.addTranslateC(.{
        .root_source_file = b.path("thirdparty/glad/khr.c"),
        .target = target,
        .optimize = optimize,
    });
    khr_c.addIncludePath(b.path("thirdparty/glad/include"));

    const sdl_c = b.addTranslateC(.{
        .root_source_file = b.path("thirdparty/sdl/sdl.c"),
        .target = target,
        .optimize = optimize,
    });
    sdl_c.linkSystemLibrary("SDL2", .{});

    // Zig libraries / abstractions
    const shader = b.addModule("shader", .{
        .root_source_file = b.path("src/shader.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "prog",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const glad = glad_c.createModule();

    exe.root_module.addImport("glad", glad);
    exe.root_module.addImport("khr", khr_c.createModule());
    exe.root_module.addImport("sdl", sdl_c.createModule());

    exe.root_module.addImport("shader", shader);
    shader.addImport("glad", glad);

    b.installArtifact(exe);
}
