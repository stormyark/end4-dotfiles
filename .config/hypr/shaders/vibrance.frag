#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);

    // Calculate luminance (grayscale)
    vec3 lumaWeights = vec3(0.2126, 0.7152, 0.0722);
    float luminance = dot(color.rgb, lumaWeights);
    vec3 gray = vec3(luminance);

    // Saturation level: 1.0 is normal, 1.5 is strong, 2.0 is extreme
    float saturation = 1.9; 

    // Mix image with modified saturation
    fragColor = vec4(mix(gray, color.rgb, saturation), color.a);
}
