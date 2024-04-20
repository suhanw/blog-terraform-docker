const path = require("path");

const isDev = !process.env.NODE_ENV || process.env.NODE_ENV === "development";

module.exports = {
  mode: !isDev ? "production" : "development",

  devtool: isDev && "source-map",

  module: {
    rules: [
      {
        test: /\.(ts|tsx)?$/,
        exclude: /node_modules/,
        use: ["ts-loader"],
      },
    ],
  },

  resolve: {
    extensions: [".ts", ".tsx"],
  },
};
