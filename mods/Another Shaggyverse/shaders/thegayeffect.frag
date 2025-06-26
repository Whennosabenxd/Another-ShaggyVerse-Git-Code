#pragma header
uniform float iTime;
uniform float enableRainbowEffect;
uniform float enableGrayEffect;
uniform float strength;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor

vec4 overlay(vec4 target, vec4 blend, float factor) {
    float gray = dot(target.rgb, vec3(0.21, 0.71, 0.07));
    vec4 mixedColor;

    if (gray > 0.5) {
        mixedColor = mix(target, blend, (1.0 - (1.0 - 2.0 * (gray - 0.5)) * (1.0 - blend.a)));
    } else {
        mixedColor = mix(target, blend, (2.0 * gray * blend.a));
    }

    return mix(target, mixedColor, factor);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord;
    vec4 text = texture(iChannel0, uv);

    float grayValue = dot(text.rgb, vec3(0.299, 0.587, 0.114));
    text.rgb = mix(text.rgb, vec3(grayValue), enableGrayEffect);

    vec4 rainbow = vec4(0.5 + 0.5 * cos(iTime * 5.0 + uv.xyx * strength + vec3(0, 2, 4)), 1.0);
    rainbow.rgb = pow(rainbow.rgb, vec3(2.2));

    fragColor = mix(text, overlay(text, rainbow, 1.0), enableRainbowEffect);
}

void main() {
    mainImage(fragColor, openfl_TextureCoordv);
}