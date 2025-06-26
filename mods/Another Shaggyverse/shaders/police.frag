#pragma header

#define round(a) floor(a + 0.5)
#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
#define texture flixel_texture2D
uniform float SPEED;

float whoop(in vec2 u, float s, in float t) {
    float a = atan(u.y, u.x);
    float d = fract((sin(s * t + a) + 1.) * .5);
    return length(vec2(sin(a), cos(a)) * d) * .7;
}

void mainImage(out vec4 O, in vec2 v) {
    vec2 r = iResolution.xy;
    // Don't change the screen size, do not distort the coordinates
    v = v / r.xy; // Normalizing coordinates to avoid screen size changes

    float t = iTime * SPEED,
          a = whoop(v, 1.3, t * .7),
          b = whoop(v - vec2(-.6, 0), 1.7, t * .5);
    
    // Sample background color (background texture)
    vec3 bgColor = texture2D(iChannel0, v).rgb;  // Get background texture color

    // Define foreground colors (blue and red)
    vec3 fgBlue = vec3(0.0, 0.0, 1.0);  // Blue color
    vec3 fgRed = vec3(1, 0.0, 0.0);   // Red color

    // Mix foreground (blue and red) with the background
    float mixFactor = 0.5 + (a - b) * 0.9;

    // Mix the blue and red colors with the background color
    vec3 mixedBlue = mix(fgBlue, bgColor, mixFactor);
    vec3 mixedRed = mix(fgRed, bgColor, mixFactor);

    // Final mixed color: Blend both blue and red colors
    vec3 finalColor = mix(mixedBlue, mixedRed, mixFactor);

    // Apply opacity to the final color
    float opacity = 0.1;  // Adjust opacity as needed
    O.xyz = finalColor;
    O.a = opacity;  // Apply opacity
}

void main() {
    mainImage(gl_FragColor, openfl_TextureCoordv * openfl_TextureSize);
}