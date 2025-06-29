import { Routes, Route } from "react-router-dom";

function App() {
  return (
    <Routes>
      <Route path="/" element={<div>main</div>} />
      <Route path="/log-in" element={<div>login</div>} />
      <Route path="/sign-up" element={<div>signup</div>} />
    </Routes>
  );
}

export default App;
