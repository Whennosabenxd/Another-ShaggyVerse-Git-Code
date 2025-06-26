// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define round(a) floor(a + 0.5)
#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
uniform float distance;
uniform float wave;
uniform float size;
#define iChannel0 bitmap
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
#define texture flixel_texture2D





void mainImage( out vec4 C, in vec2 R )
{
    R = (R.xy / iResolution.xy - .0) + cos(iTime) * distance;

    R.x *= size + pow(sin(iTime + R.y * wave), 10.);
    //C -= C; // mac fix - clear color;
    R *= sin(R * 30.);
    C += -C + ceil(R.x * R.y) * .1;
}


void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}