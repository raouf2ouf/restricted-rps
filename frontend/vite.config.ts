import legacy from "@vitejs/plugin-legacy";
import react from "@vitejs/plugin-react";
import tsconfigPaths from "vite-tsconfig-paths";
import { defineConfig } from "vite";
import { nodePolyfills } from "vite-plugin-node-polyfills";

import type { UserConfig as VitestUserConfig } from "vitest/config";

const vitestConfig: VitestUserConfig = {
  test: {
    experimentalVmThreads: true,
    include: ["src/**/*.{test,spec}.{js,ts,jsx,tsx}"],
    globals: true,
    environment: "jsdom",
    setupFiles: "./src/setupTests.ts",
    coverage: {
      provider: "v8",
      include: ["src/**/*.{ts,tsx}"],
      exclude: ["src/**/*.interface.ts"],
      all: true,
      reporter: ["text", "json-summary", "json", "html"],
      lines: 80,
      branches: 80,
      statements: 80,
    },
  },
};

// https://vitejs.dev/config/
export default defineConfig({
  test: vitestConfig.test,
  plugins: [
    react(),
    legacy(),
    tsconfigPaths(),
    nodePolyfills({
      globals: {
        Buffer: true,
        global: true,
        process: true,
      },
    }),
  ],
});
