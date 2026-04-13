#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferPreviousModelView;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    //Motion Blur
    vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);
    float depth = texture(depthtex0, texcoord).r;

    vec4 ndc = vec4(texcoord, depth, 1) * 2 - 1;
    vec4 viewPos = gbufferProjectionInverse * ndc;
    viewPos /= viewPos.w;
    vec4 worldPos = gbufferModelViewInverse * viewPos;
    worldPos.xyz += cameraPosition;

    vec4 prevWorldPos = worldPos;
    prevWorldPos.xyz -= previousCameraPosition;
    
    vec4 prevClipPos = gbufferPreviousProjection * (gbufferPreviousModelView * prevWorldPos);
    prevClipPos /= prevClipPos.w;
    vec2 prevTexcoord = prevClipPos.xy * 0.5 + 0.5;

    vec2 velocity = texcoord - prevTexcoord;

    float strength = 1.2;
    int samples = 6;
    vec3 finalColor = texture(colortex0, texcoord).rgb;

    if (depth <= 1.0 && depth > 0.56) {
        for (int i = 1; i < samples; i++) {
            vec2 offset = velocity * (float(i) / float(samples - 1) - 0.5) * strength;
            finalColor += texture(colortex0, texcoord + offset).rgb;
        }
        finalColor /= float(samples);
    }

    color = vec4(finalColor, 1.0);
    color.rgb = pow(color.rgb, vec3(1.2));

}