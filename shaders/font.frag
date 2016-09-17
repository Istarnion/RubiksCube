#version 330

in vec2 tex;

out vec4 outColor;

uniform vec3 color;
uniform sampler2D font;

void main()
{
    vec4 col = texture(font, tex) * vec4(color, 1.0);
    float colorMagnitude = col.r + col.g + col.b;
    if(colorMagnitude < 0.5)
    {
        col.a = 0.0;
    }

    outColor = col;
}

