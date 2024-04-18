const path = require("path");

const isDev = !process.env.NODE_ENV || process.env.NODE_ENV === "development";

module.exports = {
  mode: !isDev ? "production" : "development",

  target: "web",

  entry: "./src/client/index.tsx",

  devtool: isDev && "source-map",

  output: {
    path: path.join(process.cwd(), "./build"),
    filename: "bundle.js",
  },

  module: {
    rules: [
      {
        test: /\.(ts|tsx)?$/,
        exclude: /node_modules/,
        use: ["babel-loader", "ts-loader"],
      },
    ],
  },

  resolve: {
    extensions: [".ts", ".tsx"],
  },
};
