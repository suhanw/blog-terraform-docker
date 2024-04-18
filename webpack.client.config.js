const path = require("path");
const { merge } = require("webpack-merge");
const sharedConfig = require("./webpack.shared.config.js");

console.log("using webpack.client.config.js");

module.exports = merge(sharedConfig, {
  target: "web",

  entry: "./src/client/index.tsx",

  output: {
    path: path.join(process.cwd(), "./dist/client"),
    filename: "bundle.js",
  },
});
