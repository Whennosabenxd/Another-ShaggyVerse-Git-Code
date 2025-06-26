#pragma header

uniform float effect;// arriba y abajo
uniform float effect2;//derecha y izquierda
uniform float angle1;
uniform float angle2;

vec2 rotate(vec2 p, float a, vec2 center)
{
    p -= center;
    float cosA = cos(a);
    float sinA = sin(a);
    p = vec2(
        cosA * p.x - sinA * p.y,
        sinA * p.x + cosA * p.y
    );
    return p + center;
}

void main()
{
    vec2 uv = openfl_TextureCoordv.xy;
    vec4 Color = flixel_texture2D(bitmap, uv);

    vec2 uv1 = rotate(uv, angle1, vec2(0.5));
    vec2 uv2 = rotate(uv, angle2, vec2(0.5));

    if (uv1.y < effect || uv1.y > 1.0 - effect || 
        uv2.x < effect2 || uv2.x > 1.0 - effect2)
    {
        Color = vec4(0.0, 0.0, 0.0, 1.0); 
    }

    gl_FragColor = Color;
}
