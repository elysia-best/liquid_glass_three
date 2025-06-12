import * as THREE from "three";
import vertexShader from "./vertex.glsl?raw";
import fragmentShader from "./fragment.glsl?raw";

// 创建场景、相机、渲染器
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(
  45,
  window.innerWidth / window.innerHeight,
  0.1,
  1000
);
camera.position.z = 3;

const renderer = new THREE.WebGLRenderer({
  canvas: document.getElementById("glCanvas"),
  antialias: true,
});
renderer.setSize(window.innerWidth, window.innerHeight);

// 加载纹理
const texture = new THREE.TextureLoader().load("/iChannel0.png");

// uniforms
const uniforms = {
  resolution: {
    value: new THREE.Vector2(window.innerWidth, window.innerHeight),
  },
  mouse: { value: new THREE.Vector2(0, 0) },
  time: { value: 0.0 },
  iChannel0: { value: texture },
};

// Shader 材质
const material = new THREE.ShaderMaterial({
  uniforms,
  vertexShader,
  fragmentShader,
});

// 球体模型
const geometry = new THREE.SphereGeometry(1, 64, 64);
const mesh = new THREE.Mesh(geometry, material);
scene.add(mesh);

// 鼠标事件
window.addEventListener("mousemove", (e) => {
  uniforms.mouse.value.x = e.clientX;
  uniforms.mouse.value.y = window.innerHeight - e.clientY;
});

// 自适应窗口
window.addEventListener("resize", () => {
  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  uniforms.resolution.value.set(window.innerWidth, window.innerHeight);
});

// 动画循环
function animate(time) {
  uniforms.time.value = time * 0.001;
  mesh.rotation.y += 0.003;
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
animate();
