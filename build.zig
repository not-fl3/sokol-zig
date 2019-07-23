const std = @import("std");
const builtin = @import("builtin");

const Builder = std.build.Builder;
const warn = std.debug.warn;
const assert = std.debug.assert;

fn compile_shader(b: *Builder, input: []const u8, output: []const u8, slang: []const u8) *std.build.RunStep {
    return b.addSystemCommand([_][]const u8{
        "./sokol/bin/linux/sokol-shdc",
        "--input",
        input,
        "--output",
        output,
        "--slang",
        slang,
    });
}

pub fn build(b: *Builder) void {
    //    const c_args = build_c_args(b) catch unreachable;
    //const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("bla", "src/main.zig");
    exe.addCSourceFile("sokol/sokol.c", [_][]const u8{ "-std=c99", "-DSOKOL_GLCORE33" });
    exe.addCSourceFile("src/shaders.c", [_][]const u8{ "-std=c99", "-DSOKOL_GLCORE33" });
    exe.addIncludeDir("sokol");
    exe.addIncludeDir("src");
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("X11");
    exe.linkSystemLibrary("GL");

    const shader = compile_shader(b, "./src/triangle-sapp.glsl", "./src/triangle-sapp.glsl.h", "glsl330");
    exe.step.dependOn(&shader.step);

    const run_cmd = exe.run();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
