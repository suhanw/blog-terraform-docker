import esbuild from "esbuild";
import { createBuildSettings } from "../esbuild.base.mjs";

const settings = createBuildSettings({
  platform: "browser",
  entryPoints: ["client/src/index.tsx"],
  outfile: "dist/client/bundle.js",
  tsconfigPath: "client/tsconfig.json",
  tsx: true,
  target: ["chrome58", "firefox57", "safari11"],
});

console.log({ clientSettings: settings });

await esbuild.build(settings);
