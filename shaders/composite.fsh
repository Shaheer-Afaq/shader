#version 330 compatibility

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter; 
uniform int isEyeInWater;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    vec2 distortedCoord = texcoord;

    if (isEyeInWater == 1) {
        float speed = frameTimeCounter * 2.5;
        distortedCoord.x += sin(texcoord.y * 25.0 + speed) * 0.0025;
        distortedCoord.y += cos(texcoord.x * 20.0 + speed) * 0.0020;
    } 
    else if (isEyeInWater == 2) {
        float speed = frameTimeCounter * 1.2;
        distortedCoord.x += sin(texcoord.y * 12.0 + speed) * 0.005;
        distortedCoord.y += cos(texcoord.x * 10.0 + speed) * 0.005;
    }

    vec3 finalColor = texture(colortex0, distortedCoord).rgb;

    if (isEyeInWater == 1) {
        finalColor *= vec3(0.8, 0.8, 1);
    } else if (isEyeInWater == 2) {
        finalColor *= vec3(1.0, 0.5, 0.2);
    }

    color = vec4(finalColor, 1.0);
}