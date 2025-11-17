import React from "react";
import GetInToch from "../components/GetInToch.jsx";
import FeaturesHome from "../components/FeaturesHome.jsx";
import Hero from "../components/Hero.jsx";
import Navbar from "../components/NavBar.jsx";

const Home = () => {
  return (
    <div>
      <Navbar />
      <Hero />
      <FeaturesHome />
      <GetInToch />
    </div>
  );
};

export default Home;
