#pragma header

uniform float strength;
uniform float iTime;

void main(void)
{
    vec2 uv = openfl_TextureCoordv.xy;
    vec4 col;
    col.r = texture2D(bitmap, vec2(uv.x + 0.01 * strength, uv.y)).r;
    col.g = texture2D(bitmap, vec2(uv.x, uv.y)).g;
    col.b = texture2D(bitmap, vec2(uv.x - 0.01 * strength, uv.y)).b;
    col.a = texture2D(bitmap, vec2(uv.x + 0.01 * strength, uv.y)).a + texture2D(bitmap, vec2(uv.x - 0.01 * strength, uv.y)).a;

    gl_FragColor = col;
}