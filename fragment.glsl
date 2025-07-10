precision highp float;

uniform vec2 resolution;
uniform vec2 mouse;
uniform sampler2D iChannel0;
varying vec2 vUv;

vec4 blur5(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.3333333333333333) * direction;
  color += texture2D(image, uv) * 0.29411764705882354;
  color += texture2D(image, uv + (off1 / resolution)) * 0.35294117647058826;
  color += texture2D(image, uv - (off1 / resolution)) * 0.35294117647058826;
  return color; 
}

void main() {
    vec2 fragCoord = vUv * resolution;
    vec2 uv = fragCoord / resolution;
    vec2 m = mouse;
    if (length(m) < 1.0) {
        m = resolution / 2.0;
    }
    vec2 m2 = (uv - m / resolution);

    float roundedBox = pow(abs(m2.x * resolution.x / resolution.y), 8.0) + pow(abs(m2.y), 8.0);
    float rb1 = clamp((1.0 - roundedBox * 10000.0) * 8.0, 0., 1.);
    float rb2 = clamp((0.95 - roundedBox * 9500.0) * 16.0, 0., 1.) -
                clamp(pow(0.9 - roundedBox * 9500.0, 1.0) * 16.0, 0., 1.);
    float rb3 = clamp((1.5 - roundedBox * 11000.0) * 2.0, 0., 1.) -
                clamp(pow(1.0 - roundedBox * 11000.0, 1.0) * 2.0, 0., 1.);

    float transition = smoothstep(0.0, 1.0, rb1 + rb2);

    vec4 fragColor = texture2D(iChannel0, uv);

    if (transition > 0.0) {
        // 控制变形参数
        float distortionFactor = (1.0 - roundedBox * 5000.0);
        vec2 lens = ((uv - 0.5) * 1.0 * distortionFactor + 0.5);

        // 应用blur
        vec4 blurred = blur5(iChannel0, lens, resolution.xy, vec2(1.0, 0.0));

        // 计算渐变光效
        float gradient = clamp((clamp(m2.y, 0.0, 0.2) + 0.1) / 2.0, 0., 1.) +
                         clamp((clamp(-m2.y, -1000.0, 0.2) * rb3 + 0.1) / 2.0, 0., 1.);

        vec4 lighting = clamp(blurred + vec4(rb1) * gradient + vec4(rb2) * 0.3, 0.0, 1.0);
        fragColor = mix(fragColor, lighting, transition);
    }

    gl_FragColor = fragColor;
}