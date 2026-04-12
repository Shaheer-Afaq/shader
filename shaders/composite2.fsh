#version 330 compatibility

uniform sampler2D colortex0; // Result from composite1 (Depth + Motion blurred)
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    vec3 textureColor = texture(colortex0, texcoord).rgb;
    textureColor *= vec3(1.1, 1.1, 1);
    textureColor -= vec3(0.05);
    color = vec4(textureColor, 1.0);
}