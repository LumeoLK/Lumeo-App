export default function Navbar() { return (
<nav className="bg-gray-800 text-white p-4">
  <div className="container mx-auto flex justify-between items-center">
    <div className="text-xl font-bold">Logo</div>
    <div className="flex gap-6">
      <a href="#home" className="hover:text-gray-300 transition-colors">
        Home
      </a>
      <a href="#about" className="hover:text-gray-300 transition-colors">
        About
      </a>
      <a href="#contact" className="hover:text-gray-300 transition-colors">
        Contact
      </a>
    </div>
  </div>
</nav>
); }
