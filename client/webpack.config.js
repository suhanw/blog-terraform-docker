const path = require("path");
const { merge } = require("webpack-merge");
const sharedConfig = require("../webpack.base.config.js");

module.exports = merge(sharedConfig, {
  target: "web",

  entry: path.join(process.cwd(), "client/src/index.tsx"),

  output: {
    path: path.join(process.cwd(), "dist/client"),
    filename: "bundle.js",
  },
});
