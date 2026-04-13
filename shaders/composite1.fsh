#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    //Focus Blur
    vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);
    float depth = texture(depthtex0, texcoord).r;

    float focusDepth = texture(depthtex0, vec2(0.5)).r;
    float depthDiff = abs(depth - focusDepth);
    
    float focusRange = 0.05; 
    float strength = 7.0; 
    float blur = smoothstep(0.0, focusRange, depthDiff) * strength;

    vec3 finalColor = vec3(0.0);
    float runs = 0.0;
    int radius = int(blur); 

    if (radius <= 0 || depth <= 0.56) {
        finalColor = texture(colortex0, texcoord).rgb;
    } else {
        // radius = min(radius, 10); 
        for (int x = -radius; x <= radius; x++) {
            for (int y = -radius; y <= radius; y++) {
                vec2 offset = vec2(float(x), float(y)) * texelSize;
                finalColor += texture(colortex0, texcoord + offset).rgb;
                runs += 1.0;
            }
        }
        finalColor /= runs;
    }

    color = vec4(finalColor, 1.0);
}