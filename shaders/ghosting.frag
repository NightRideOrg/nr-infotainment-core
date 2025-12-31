#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

// Samplers defined in QML
layout(binding = 1) uniform sampler2D targetTexture;
layout(binding = 2) uniform sampler2D historyTexture;

// Uniform Block
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float blendFactor; // This matches the property in QML
};

void main() {
    vec4 target = texture(targetTexture, qt_TexCoord0);
    vec4 history = texture(historyTexture, qt_TexCoord0);

    // If blendFactor is 1.0, we show target immediately.
    // If 0.1, we show mostly history.
    fragColor = mix(history, target, blendFactor) * qt_Opacity;
}
