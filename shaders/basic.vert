#version 330

layout(location=0) in vec3 position;
layout(location=1) in vec3 color;
layout(location=2) in vec3 normal;
layout(location=3) in vec2 tex;

out vec3 fragment_color;
out vec3 normalDir;
out vec2 texCoord;

uniform mat4 MVP;

void main()
{
    fragment_color = color;
    texCoord = tex;
    normalDir = normalize(MVP * vec4(normal, 0)).xyz;
    gl_Position = MVP * vec4(position, 1.0);
}

