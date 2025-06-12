import { defineConfig } from "vite";

export default defineConfig({
  base: "./",
  assetsInclude: ["**/*.glsl"],
  server: {
    open: true,
  },
  build: {
    outDir: "docs",
  },
});
