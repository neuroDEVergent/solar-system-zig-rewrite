const std = @import("std");
const glad = @import("glad");

pub fn init(shaderID: *glad.GLuint, vertexPath: []const u8, fragmentPath: []const u8, io: std.Io, gpa: std.mem.Allocator) !void {
    const vertex = try ReadFileAsString(io, gpa, vertexPath);
    defer gpa.free(vertex);

    const fragment = try ReadFileAsString(io, gpa, fragmentPath);
    defer gpa.free(fragment);

    var vertexObject: glad.GLuint = 0;
    vertexObject = glad.glCreateShader(glad.GL_VERTEX_SHADER);

    var fragmentObject: glad.GLuint = 0;
    fragmentObject = glad.glCreateShader(glad.GL_FRAGMENT_SHADER);

    const vertexC = try gpa.dupeZ(u8, vertex);
    defer gpa.free(vertexC);

    const fragmentC = try gpa.dupeZ(u8, fragment);
    defer gpa.free(fragmentC);

    const vertexArr = [_][*:0]const u8 { vertexC };
    const fragmentArr = [_][*:0]const u8 { fragmentC };

    _ = glad.glShaderSource(vertexObject, 1, &vertexArr[0], null);
    _ = glad.glCompileShader(vertexObject);

    _ = glad.glShaderSource(fragmentObject, 1, &fragmentArr[0], null);
    _ = glad.glCompileShader(fragmentObject);

     shaderID.* = glad.glCreateProgram();

    _ = glad.glAttachShader(shaderID.*, vertexObject);
    _ = glad.glAttachShader(shaderID.*, fragmentObject);
    _ = glad.glLinkProgram(shaderID.*);
}


fn ReadFileAsString(io: std.Io, gpa: std.mem.Allocator, path: []const u8) ![]u8
{
    return std.Io.Dir.cwd().readFileAlloc(io, path, gpa, .unlimited);
}


