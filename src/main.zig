const std = @import("std");
const sdl = @import("sdl");
const glad = @import("glad");
const khr = @import("khr");
const shader = @import("shader");

var gQuit: bool = false;

pub fn main(init: std.process.Init) !void
{
    const gScreenWidth: u16 = 1280;
    const gScreenHeight: u16 = 720;
    var gGraphicsApplicationWindow: ?*sdl.SDL_Window = null;
    var gOpenGLContext: ?sdl.SDL_GLContext = null;

    var gVAO: glad.GLuint = 0;
    var gVBO: glad.GLuint = 0;
//    var gPipeline: glad.GLuint = 0;

    // Initialize the program
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) < 0)
    {
        std.debug.print("SDL2 could not initialize video subsystem\n", .{});
    }

    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 4);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 1);

    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_PROFILE_MASK, sdl.SDL_GL_CONTEXT_PROFILE_CORE);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_DOUBLEBUFFER, 1);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_DEPTH_SIZE, 2);

    gGraphicsApplicationWindow = sdl.SDL_CreateWindow("OpenGL Window", 0, 0, gScreenWidth, gScreenHeight, sdl.SDL_WINDOW_OPENGL);

    if (gGraphicsApplicationWindow == null)
    {
        std.debug.print("SDL Window was not able to be created\n", .{});
    }

    gOpenGLContext = sdl.SDL_GL_CreateContext(gGraphicsApplicationWindow);

    if (gOpenGLContext == null)
    {
        std.debug.print("OpenGL context could not be created\n", .{});
    }

    // Initialize the Glad library
    if (glad.gladLoadGLLoader(sdl.SDL_GL_GetProcAddress) == 0)
    {
        std.debug.print("Glad was not initialized\n", .{});
    }

    GetOpenGLVersionInfo();

    // Vertex Specification
    const vertices: [18]glad.GLfloat = .{
        // x     y     z  r    g    b
        -0.8, -0.8,  0.0, 1.0, 0.0, 0.0,
         0.8, -0.8,  0.0, 0.0, 1.0, 0.0,
         0.0,  0.8,  0.0, 0.0, 0.0, 1.0
    };

    glad.glGenVertexArrays(1, &gVAO);
    glad.glBindVertexArray(gVAO);

    // generate VBO
    glad.glGenBuffers(1, &gVBO);
    glad.glBindBuffer(glad.GL_ARRAY_BUFFER, gVBO);
    glad.glBufferData(glad.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, glad.GL_STATIC_DRAW);

    // Handle VAO
    glad.glBindBuffer(glad.GL_ARRAY_BUFFER, gVBO);
    glad.glEnableVertexAttribArray(0);
    glad.glVertexAttribPointer(0, 3, glad.GL_FLOAT, glad.GL_FALSE, 6 * @sizeOf(glad.GLfloat), @ptrFromInt(0));
    glad.glEnableVertexAttribArray(1);
    glad.glVertexAttribPointer(1, 3, glad.GL_FLOAT, glad.GL_FALSE, 6 * @sizeOf(glad.GLfloat), @ptrFromInt(3 * @sizeOf(glad.GLfloat)));
    glad.glBindVertexArray(0);

    // Read a file
    const io = init.io;
    const gpa = init.gpa;

    var defaultShader: glad.GLuint = 0;
    try shader.init(&defaultShader, "./shaders/vert.glsl", "./shaders/frag.glsl", io, gpa);

    while (!gQuit)
    {
        // Input
        Input();

        // Draw
        glad.glDisable(glad.GL_DEPTH_TEST);
        glad.glDisable(glad.GL_CULL_FACE);
        glad.glViewport(0, 0, gScreenWidth, gScreenHeight);
        glad.glClearColor(0, 0, 0, 1.0);

        glad.glClear(glad.GL_DEPTH_BUFFER_BIT | glad.GL_COLOR_BUFFER_BIT);

        glad.glUseProgram(defaultShader);

        glad.glBindVertexArray(gVAO);
        glad.glBindBuffer(glad.GL_ARRAY_BUFFER, gVAO);

        glad.glDrawArrays(glad.GL_TRIANGLES, 0, 3);

        sdl.SDL_GL_SwapWindow(gGraphicsApplicationWindow);

    }

    // Cleanup
    sdl.SDL_DestroyWindow(gGraphicsApplicationWindow);
    sdl.SDL_Quit();


}

fn GetOpenGLVersionInfo() void
{
    std.debug.print("Vendor: {s}\n", .{glad.glGetString(glad.GL_VENDOR)});
    std.debug.print("Renderer: {s}\n", .{glad.glGetString(glad.GL_RENDERER)});
    std.debug.print("Version: {s}\n", .{glad.glGetString(glad.GL_VERSION)});
    std.debug.print("Shading Language: {s}\n", .{glad.glGetString(glad.GL_SHADING_LANGUAGE_VERSION)});
   
}

fn Input() void
{
    var e: sdl.SDL_Event = undefined;

    while (sdl.SDL_PollEvent(&e) != 0)
    {
        if (e.type == sdl.SDL_QUIT)
        {
            std.debug.print("Goodbye\n", .{});
            gQuit = true;
        }
    }
    
}
