import React from "react";
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";

import Header from "./components/Header";
import Footer from "./components/Footer";

import RegisterCompany from "./pages/RegisterCompany";
import AddRoom from "./pages/AddRoom";
import ViewCompanies from "./pages/ViewCompanies";
import ViewAllRooms from "./pages/ViewRooms";
import Signup from './pages/Signup'; 
import Login from "./pages/Login";
import ProtectedRoute from "./components/ProtectedRoute"; 

const App: React.FC = () => {
  return (
    <Router>
      <div style={{ display: "flex", flexDirection: "column", minHeight: "100vh" }}>
        <Header />

        <main style={{ flex: 1, padding: 20 }}>
          <Routes>
            <Route path="/" element={<Navigate to="/login" />} />
            <Route path="/login" element={<Login />} />
            <Route path="/signup" element={<Signup />} />

            {/* Protected routes */}
            <Route
              path="/register-company"
              element={
                <ProtectedRoute>
                  <RegisterCompany />
                </ProtectedRoute>
              }
            />
            <Route
              path="/add-room"
              element={
                <ProtectedRoute>
                  <AddRoom />
                </ProtectedRoute>
              }
            />
            <Route
              path="/rooms"
              element={
                <ProtectedRoute>
                  <ViewAllRooms />
                </ProtectedRoute>
              }
            />
            <Route
              path="/companies"
              element={
                <ProtectedRoute>
                  <ViewCompanies />
                </ProtectedRoute>
              }
            />
          </Routes>
        </main>

        <Footer />
      </div>
    </Router>
  );
};

export default App;
