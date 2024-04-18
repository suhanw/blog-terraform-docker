const path = require("path");
const { merge } = require("webpack-merge");
const nodeExternals = require("webpack-node-externals");
const sharedConfig = require("./webpack.shared.config.js");

console.log("using webpack.server.config.js");

module.exports = merge(sharedConfig, {
  target: "node",

  entry: "./src/server/index.ts",

  output: {
    path: path.join(process.cwd(), "./dist/server"),
    filename: "index.js",
  },

  externals: [nodeExternals()], // in order to ignore all modules in node_modules folder
});
