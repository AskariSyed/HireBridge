import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import "../css/Header.css";

const Header: React.FC = () => {
  const [menuOpen, setMenuOpen] = useState(false);
  const navigate = useNavigate();
  const isLoggedIn = !!localStorage.getItem("token");

  const toggleMenu = () => setMenuOpen(!menuOpen);

  const handleLogout = () => {
    localStorage.removeItem("token");  // Clear token
    setMenuOpen(false);
    navigate("/login"); // Redirect to login page
  };

  return (
    <header className="header">
      <h1>HireBridge</h1>
      <button
        className="menu-toggle"
        onClick={toggleMenu}
        aria-label="Toggle menu"
        aria-expanded={menuOpen}
      >
        &#9776;
      </button>
      <nav className={menuOpen ? "nav open" : "nav"}>
        <Link to="/register-company" onClick={() => setMenuOpen(false)}>Register Company</Link>
        <Link to="/add-room" onClick={() => setMenuOpen(false)}>Add Room</Link>
        <Link to="/rooms" onClick={() => setMenuOpen(false)}>View All Rooms</Link>
        <Link to="/companies" onClick={() => setMenuOpen(false)}>View All Companies</Link>
       {isLoggedIn && (
        <button 
          onClick={handleLogout} 
          className="logout-button" 
          style={{ marginTop: '10px', backgroundColor: '#dc3545', border: 'none', color: 'white', padding: '8px 12px', borderRadius: '5px', cursor: 'pointer', width: '100%' }}
        >
          Logout
        </button>)}
      </nav>
    </header>
  );
};

export default Header;
