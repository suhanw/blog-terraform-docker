import esbuildPluginTsc from "esbuild-plugin-tsc";

const isDev = !process.env.NODE_ENV || process.env.NODE_ENV === "development";

export function createBuildSettings({ tsconfigPath, tsx, ...restOptions }) {
  return {
    minify: !isDev,
    sourcemap: isDev, 
    bundle: true,
    plugins: [
      esbuildPluginTsc({
        force: true,
        tsconfigPath,
        tsx,
      }),
    ],
    ...restOptions,
  };
}
