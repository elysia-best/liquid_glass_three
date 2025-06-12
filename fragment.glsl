precision highp float;

uniform vec2 resolution;
uniform vec2 mouse;
uniform sampler2D iChannel0;
varying vec2 vUv;

void main() {
    // 适配Shadertoy变量
    vec2 fragCoord = vUv * resolution;
    vec2 uv = fragCoord / resolution;
    vec2 m = mouse;
    if (length(m) < 1.0) {
        m = resolution / 2.0;
    }
    vec2 m2 = (uv - m / resolution);

    float roundedBox = pow(abs(m2.x * resolution.x / resolution.y), 8.0) + pow(abs(m2.y), 8.0);
    float rb1 = clamp((1.0 - roundedBox * 10000.0) * 8.0, 0., 1.); // rounded box
    float rb2 = clamp((0.95 - roundedBox * 9500.0) * 16.0, 0., 1.) - clamp(pow(0.9 - roundedBox * 9500.0, 1.0) * 16.0, 0., 1.); // borders
    float rb3 = (clamp((1.5 - roundedBox * 11000.0) * 2.0, 0., 1.) - clamp(pow(1.0 - roundedBox * 11000.0, 1.0) * 2.0, 0., 1.)); // shadow gradient

    vec4 fragColor = vec4(0.0);
    float transition = smoothstep(0.0, 1.0, rb1 + rb2);

    if (transition > 0.0) {
        vec2 lens;
        lens = ((uv - 0.5) * 1.0 * (1.0 - roundedBox * 5000.0) + 0.5);
        float total = 0.0;
        for (float x = -4.0; x <= 4.0; x++) {
            for (float y = -4.0; y <= 4.0; y++) {
                vec2 offset = vec2(x, y) * 0.5 / resolution;
                fragColor += texture2D(iChannel0, offset + lens);
                total += 1.0;
            }
        }
        fragColor /= total;
        float gradient = clamp((clamp(m2.y, 0.0, 0.2) + 0.1) / 2.0, 0., 1.) + clamp((clamp(-m2.y, -1000.0, 0.2) * rb3 + 0.1) / 2.0, 0., 1.);
        vec4 lighting = clamp(fragColor + vec4(rb1) * gradient + vec4(rb2) * 0.3, 0., 1.);
        fragColor = mix(texture2D(iChannel0, uv), lighting, transition);
    } else {
        fragColor = texture2D(iChannel0, uv);
    }
    gl_FragColor = fragColor;
} 