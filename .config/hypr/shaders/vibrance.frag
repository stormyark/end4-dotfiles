precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    float average = (color.r + color.g + color.b) / 3.0;
    float saturation = 1.5; // HIER den Wert anpassen!
    color.rgb = average + saturation * (color.rgb - average);
    gl_FragColor = color;
}
