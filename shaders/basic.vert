#version 330

layout(location=0) in vec3 position;
layout(location=1) in vec3 color;

out vec3 fragment_color;

uniform mat4 MVP;

void main()
{
    fragment_color = color;
    gl_Position = MVP * vec4(position, 1.0);
}

