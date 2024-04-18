console.log("using babel.config.js");

module.exports = function (api) {
  api.cache(false);

  let presets = [["@babel/preset-env"]];

  let plugins = [];

  return {
    presets,
    plugins,
  };
};
