import React from "react";
import { Link } from "react-router-dom";
import HIVEImg from "../assets/hive.jpg";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faEnvelope } from "@fortawesome/free-regular-svg-icons";
import {
  faLinkedin,
  faSquareInstagram,
  faSquareFacebook,
} from "@fortawesome/free-brands-svg-icons";

const Footer = () => {
  return (
    <footer className="bg-gray-700 text-white py-6 mt-10">
      <div className="container mx-auto px-4 flex flex-col md:flex-row justify-between items-center md:items-start gap-6">
        {/*logo & name*/}
        <div className="flex items-center gap-3">
          <img src={HIVEImg} alt="logo" className="w-10 h-10" />
          <h1 className="text-2xl font-bold">HIVE</h1>
        </div>

        {/*page navigation*/}
        <nav className="flex flex-col sm:flex-row gap-2 sm:gap-6 text-center md:text-left">
          <Link className="hover:text-gray-300" to="/">
            Home
          </Link>
          <Link className="hover:text-gray-300" to="/about">
            About
          </Link>
          <Link className="hover:text-gray-300" to="/Features">
            Features
          </Link>
          <Link className="hover:text-gray-300" to="/contact">
            Contact US
          </Link>
          <Link className="hover:text-gray-300" to="/privacy">
            Privacy
          </Link>
        </nav>

        {/* social media links and copyright  */}
        <div className="flex flex-col items-center md:items-end gap-2">
          <div className="flex gap-4 text-xl">
            <a
              href="https://www.linkdin.com/yourpage"
              target="_blank"
              rel="noopener noreferrer"
            >
              <FontAwesomeIcon icon={faLinkedin} />
            </a>
            <a
              href="https://www.facebook.com"
              target="_blank"
              rel="noopener noreferrer"
            >
              {" "}
              <FontAwesomeIcon icon={faSquareFacebook} />
            </a>

            <a href="mailto:6iatlascs14@gmail.com">
              <FontAwesomeIcon icon={faEnvelope} />
            </a>
            <a
              href="https://www.instagram.com"
              target="_blank"
              rel="noopener noreferrer"
            >
              <FontAwesomeIcon icon={faSquareInstagram} />
            </a>
          </div>
          <p className="text-sm text-gray-300 mt-2 text-center md:text-right">
            © 2025 HIVE. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
