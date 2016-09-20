#version 330

in vec3 fragment_color;
in vec3 normalDir;
in vec2 texCoord;

uniform sampler2D diffuse;
uniform sampler2D normal;

out vec4 color;

void main()
{
    float ambient = 0.5;

    //normal += 2.0 * texture(normal, texCoord).rgb - 1.0;

    float light = dot(normalDir, vec3(0.58, 0.58, -0.58));
    light = clamp(light, 0, 1);
    light = light + ambient;

    vec4 col = texture(diffuse, texCoord) * light;

    col.w = 1;
    color = col;
}

