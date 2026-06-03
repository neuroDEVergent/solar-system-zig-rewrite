const std = @import("std");
const sdl = @import("sdl");
const glad = @import("glad");
const khr = @import("khr");

pub fn main() !void
{
    _ = sdl.SDL_Init(0);
    _ = glad.gladLoadGL();
    std.debug.print("Hello World!\n", .{});
}
