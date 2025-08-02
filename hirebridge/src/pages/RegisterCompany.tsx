import React, { useState, ChangeEvent, FormEvent } from "react";
import "../css/RegisterCompany.css";

const RegisterCompany: React.FC = () => {
  const [formData, setFormData] = useState({
    name: "",
    hrContact: "",
    domain: "",
    numReps: 1,
    EstimatedInterviewDuration: 5, 
    username: "",
    password: "",
  });

  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleChange = (e: ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === "numReps" || name === "estimatedinterviewDuration" ? Number(value) : value,
    }));
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setMessage(null);
    setError(null);

    try {
      const response = await fetch("https://localhost:7178/api/Company/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          Name: formData.name,
          HRContact: formData.hrContact,
          Domain: formData.domain,
          NumReps: formData.numReps,
          EstimatedInterviewDuration: formData.EstimatedInterviewDuration,
          Username: formData.username,
          Password: formData.password,
        }),
        
      }
    );  if (response.status === 401) {
  if (window.confirm('Session expired. Please login again.')) {
    localStorage.removeItem('token');
    window.location.href = '/login';
  }
  return;
}

      if (!response.ok) {
        setError("Failed to register company");
        return;
      }

      const data = await response.json();
      setMessage(`Registered! Assigned Room: ${data.room}`);
      setFormData({
        name: "",
        hrContact: "",
        domain: "",
        numReps: 1,
        EstimatedInterviewDuration: 5,
        username: "",
        password: "",
      });
    } catch {
      setError("Server error during registration");
    }
  };

  return (
    <div className="register-company-container">
      <h2>Register Company</h2>
      {message && <p className="success-message">{message}</p>}
      {error && <p className="error-message">{error}</p>}

      <form onSubmit={handleSubmit}>
        <label>Company Name</label>
        <input
          type="text"
          name="name"
          placeholder="Company Name"
          value={formData.name}
          onChange={handleChange}
          required
        />

        <label>HR Contact</label>
        <input
          type="text"
          name="hrContact"
          placeholder="HR Contact"
          value={formData.hrContact}
          onChange={handleChange}
        />

        <label>Domain</label>
        <input
          type="text"
          name="domain"
          placeholder="Domain"
          value={formData.domain}
          onChange={handleChange}
        />

        <label>Number of Representatives</label>
        <input
          type="number"
          name="numReps"
          placeholder="Number of Representatives"
          value={formData.numReps}
          onChange={handleChange}
          required
          min={1}
        />

        <label>Estimated Interview Time (Manual Entry in minutes)</label>
        <input
          type="number"
          name="EstimatedInterviewDuration"
          placeholder="Estimated Interview Time (mins)"
          value={formData.EstimatedInterviewDuration}
          onChange={handleChange}
          min={1}
        />

        <label>Or Quick Select Interview Time</label>
        <select
          name="EstimatedInterviewDuration"
          value={formData.EstimatedInterviewDuration}
          onChange={handleChange}
        >
          <option value="">-- Select Interview Time --</option>
          <option value={5}>5 mins</option>
          <option value={10}>10 mins</option>
          <option value={15}>15 mins</option>
          <option value={20}>20 mins</option>
        </select>

        <label>Username</label>
        <input
          type="text"
          name="username"
          placeholder="Username"
          value={formData.username}
          onChange={handleChange}
          required
        />

        <label>Password</label>
        <input
          type="password"
          name="password"
          placeholder="Password"
          value={formData.password}
          onChange={handleChange}
          required
        />

        <button type="submit">Register Company</button>
      </form>
    </div>
  );
};

export default RegisterCompany;
