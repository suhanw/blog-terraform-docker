import esbuild from "esbuild";
import { createBuildSettings } from "../esbuild.base.mjs";

const settings = createBuildSettings({
  platform: 'node',
  entryPoints: ["server/src/index.ts"],
  outfile: "dist/server/index.js",
  tsconfigPath: "server/tsconfig.json",
  packages: 'external', // avoid bundling modules in node_modules folder
});

console.log({ serverSettings: settings });

await esbuild.build(settings);
