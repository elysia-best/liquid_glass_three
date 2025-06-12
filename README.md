# 液态玻璃着色器效果讲解

本项目实现了一个基于 WebGL/Three.js 的液态玻璃（磨砂玻璃）特效。核心视觉效果全部由片元着色器（fragment shader）实现。

---

## 1. 效果预览

![液态玻璃效果示意](docs/screenshot.png)

---

## 2. 主要着色器代码片段与讲解

### 2.1 变量与输入

```glsl
uniform vec2 resolution;   // 画布分辨率
uniform vec2 mouse;        // 鼠标位置，控制玻璃中心
uniform sampler2D iChannel0; // 背景图片纹理
varying vec2 vUv;          // 片元归一化坐标
```

### 2.2 玻璃区域的判定与形状

```glsl
vec2 fragCoord = vUv * resolution;
vec2 uv = fragCoord / resolution;
vec2 m = mouse;
if (length(m) < 1.0) {
    m = resolution / 2.0;
}
vec2 m2 = (uv - m / resolution);

float roundedBox = pow(abs(m2.x * resolution.x / resolution.y), 8.0) + pow(abs(m2.y), 8.0);
float rb1 = clamp((1.0 - roundedBox * 10000.0) * 8.0, 0., 1.); // 玻璃主体
float rb2 = clamp((0.95 - roundedBox * 9500.0) * 16.0, 0., 1.) - clamp(pow(0.9 - roundedBox * 9500.0, 1.0) * 16.0, 0., 1.); // 边缘高光
float rb3 = (clamp((1.5 - roundedBox * 11000.0) * 2.0, 0., 1.) - clamp(pow(1.0 - roundedBox * 11000.0, 1.0) * 2.0, 0., 1.)); // 阴影渐变
```

- `roundedBox` 控制玻璃的形状（近似圆角矩形/椭圆）。
- `rb1` 控制玻璃主体区域。
- `rb2` 控制玻璃边缘的高光。
- `rb3` 控制玻璃下方的阴影渐变。

### 2.3 玻璃区域的模糊采样

```glsl
vec4 fragColor = vec4(0.0);
float transition = smoothstep(0.0, 1.0, rb1 + rb2);

if (transition > 0.0) {
    vec2 lens = ((uv - 0.5) * 1.0 * (1.0 - roundedBox * 5000.0) + 0.5);
    float total = 0.0;
    for (float x = -4.0; x <= 4.0; x++) {
        for (float y = -4.0; y <= 4.0; y++) {
            vec2 offset = vec2(x, y) * 0.5 / resolution;
            fragColor += texture2D(iChannel0, offset + lens);
            total += 1.0;
        }
    }
    fragColor /= total;
```

- 通过多次采样（高斯模糊）实现玻璃的模糊折射感。
- `lens` 控制玻璃的变形和折射。

### 2.4 玻璃的高光和阴影

```glsl
    float gradient = clamp((clamp(m2.y, 0.0, 0.2) + 0.1) / 2.0, 0., 1.)
                  + clamp((clamp(-m2.y, -1000.0, 0.2) * rb3 + 0.1) / 2.0, 0., 1.);
    vec4 lighting = clamp(fragColor + vec4(rb1) * gradient + vec4(rb2) * 0.3, 0., 1.);
    fragColor = mix(texture2D(iChannel0, uv), lighting, transition);
} else {
    fragColor = texture2D(iChannel0, uv);
}
gl_FragColor = fragColor;
```

- `gradient` 让玻璃有上下渐变的高光和阴影。
- `lighting` 叠加高光和边缘效果。
- `mix` 保证玻璃外部区域为原始背景。

---

## 3. 总结

- 该着色器通过高斯模糊、多重采样、边缘高光和渐变阴影，模拟了真实的液态/磨砂玻璃视觉。
- 鼠标拖动可实时改变玻璃中心。
- 你可以通过调整采样范围、rb1/rb2/rb3 参数，获得不同的玻璃形状和质感。

---

> **提示**：如需更高质量的模糊，可增加采样次数，但会影响性能。

个人微信；chenhaiqiang32,合作可私
