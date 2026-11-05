#version 460 core
#include <flutter/runtime_effect.glsl>

// Uniforms
uniform vec2 uResolution;
uniform float uTime;
uniform float uIntensity;     // 0..1
uniform vec4 uTint;           // warna aksen
uniform float uWaveScale;     // 0.5..3
uniform float uBlurStrength;  // efek "kaca"

out vec4 fragColor;

// Simplex-ish noise (cheap 2D)
float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal noise untuk "cairan"
float fbm(vec2 p) {
  float v = 0.0;
  float amp = 0.5;
  for (int i = 0; i < 4; i++) {
    v += amp * noise(p);
    p *= 2.03;
    amp *= 0.5;
  }
  return v;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uResolution;
  vec2 centered = uv * 2.0 - 1.0;

  // Time-driven flow
  float t = uTime * 0.35;
  vec2 flow = vec2(
    fbm(centered * uWaveScale + vec2(t, 0.0)),
    fbm(centered * uWaveScale + vec2(0.0, t * 1.3))
  ) - 0.5;

  // Distortion vector
  vec2 offset = flow * uIntensity * 0.06;

  // Refraction: sample gradient of the field
  float refract = fbm(centered + offset) * 0.5 + 0.5;

  // Edge glow: makin dekat tepi, makin terang
  float edge = 1.0 - smoothstep(0.0, 1.0, length(centered));
  edge = pow(edge, 1.5);

  // Specular highlight dari arah atas-kiri
  vec2 lightDir = normalize(vec2(-0.6, -0.8));
  float spec = pow(max(dot(normalize(centered + 1e-5), lightDir), 0.0), 8.0);
  spec *= uBlurStrength * 0.4;

  // Base tint (dari aksen)
  vec3 base = uTint.rgb * (0.6 + refract * 0.4);
  vec3 glow = uTint.rgb * edge * 0.8;
  vec3 highlight = vec3(1.0) * spec;

  vec3 color = base + glow + highlight;

  // Alpha: solid di tengah, transparan di tepi ekstrem (biar menyatu)
  float alpha = clamp(edge * 0.6 + 0.55 + spec, 0.0, 1.0);
  alpha *= uTint.a;

  // Grain tipis (anti-band)
  float grain = (hash(uv * uResolution) - 0.5) * 0.015;
  color += grain;

  fragColor = vec4(color, alpha);
}