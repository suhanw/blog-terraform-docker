import esbuild from "esbuild";
import { createBuildSettings } from "../esbuild.base.mjs";

const settings = createBuildSettings({
  platform: "browser",
  entryPoints: ["client/src/index.tsx"],
  outfile: "dist/client/bundle.js",
  tsconfigPath: "client/tsconfig.json",
  tsx: true,
});

console.log({ clientSettings: settings });

await esbuild.build(settings);
