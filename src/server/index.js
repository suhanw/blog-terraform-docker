const path = require("path");
const express = require("express");
const app = express();
const port = 3000;

app.use("/build", express.static(path.join(process.cwd(), "./build")));

app.get("/", (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>My App</title>
      </head>
      <body>
        <div id="root"></div>
        <script src="/build/bundle.js"></script>
      </body>
    </html>
  `);
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
