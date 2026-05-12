#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);

    // Berechnet die Graustufen/Helligkeit (Luminance)
    vec3 lumaWeights = vec3(0.2126, 0.7152, 0.0722);
    float luminance = dot(color.rgb, lumaWeights);
    vec3 gray = vec3(luminance);

    // Sättigungswert: 1.0 ist normal, 1.5 ist stark, 2.0 ist extrem
    float saturation = 1.9; 

    // Mischt das Bild mit der neuen Sättigung zusammen
    fragColor = vec4(mix(gray, color.rgb, saturation), color.a);
}
