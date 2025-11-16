import React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Footer from "../src/components/Footer.jsx";
import Home from "../src/pages/Home.jsx";
import Features from "../src/pages/Features.jsx";
import About from "../src/pages/About.jsx";
import Contact from "../src/pages/Contact.jsx";
import Privacy from "../src/pages/Privacy.jsx";

const App = () => {
  return (
    <div>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/features" element={<Features />} />
          <Route path="/about" element={<About />} />
          <Route path="/contact" element={<Contact />} />
          <Route path="/privacy" element={<Privacy />} />
        </Routes>

        <Footer />
      </BrowserRouter>
    </div>
  );
};

export default App;
