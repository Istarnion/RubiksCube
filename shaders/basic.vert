#version 330

layout(location=0) in vec3 position;
layout(location=1) in vec3 color;
layout(location=2) in vec3 normal;

out vec3 fragment_color;
out vec3 normalDir;

uniform mat4 MVP;

void main()
{
    fragment_color = color;
    normalDir = normalize(MVP * vec4(normal, 0)).xyz;
    gl_Position = MVP * vec4(position, 1.0);
}

