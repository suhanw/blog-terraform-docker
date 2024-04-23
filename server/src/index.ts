import path from "path";
import express from "express";

const PORT = 3000;
const app = express();

app.use("/public", express.static(path.join(process.cwd(), "./dist/client")));

app.get("/", (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>My App</title>
      </head>
      <body>
        <div id="root"></div>
        <script src="/public/bundle.js"></script>
      </body>
    </html>
  `);
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
