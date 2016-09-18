#version 330

in vec3 fragment_color;
in vec3 normalDir;

out vec4 color;

void main()
{
    float ambient = 0.5;
    float light = dot(normalDir, vec3(0.58, 0.58, -0.58));
    light = clamp(light, 0, 1);
    light = light + ambient;
    vec3 col = fragment_color * clamp(light, 0, 1);
    color = vec4(col, 1.0);
}
