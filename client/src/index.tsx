import React from "react";
import { createRoot } from "react-dom/client";

function App({ message }: { message: string }) {
  return <h1>{message}</h1>;
}

window.addEventListener("DOMContentLoaded", () => {
  const root = createRoot(document.getElementById("root"));
  root.render(<App message="Hello World!!" />);
});
