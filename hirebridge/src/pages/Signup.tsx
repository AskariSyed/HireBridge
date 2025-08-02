import React, { useState, ChangeEvent, FormEvent } from "react";
import '../css/Signup.css';

const Signup: React.FC = () => {
  const [formData, setFormData] = useState({
    username: "",
    password: "",
    confirmPassword: "",
  });

  const [errors, setErrors] = useState<{ [key: string]: string }>({});
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const validate = () => {
    const newErrors: { [key: string]: string } = {};

    // Username validation: required, 3-20 chars, alphanumeric + underscore
    if (!formData.username.trim()) {
      newErrors.username = "Username is required";
    } else if (!/^[a-zA-Z0-9_]{3,20}$/.test(formData.username)) {
      newErrors.username = "Username must be 3-20 characters, alphanumeric or underscore only";
    }

    // Password validation: required, min 8 chars, uppercase, lowercase, digit, special char
    if (!formData.password) {
      newErrors.password = "Password is required";
    } else if (
      !/(?=.*[a-z])/.test(formData.password) ||
      !/(?=.*[A-Z])/.test(formData.password) ||
      !/(?=.*\d)/.test(formData.password) ||
      !/(?=.*[\W_])/.test(formData.password) ||
      formData.password.length < 8
    ) {
      newErrors.password =
        "Password must be at least 8 characters, with uppercase, lowercase, number and special character";
    }

    // Confirm password validation
    if (formData.confirmPassword !== formData.password) {
      newErrors.confirmPassword = "Passwords do not match";
    }

    setErrors(newErrors);

    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));

    // Clear error as user types
    setErrors((prev) => ({
      ...prev,
      [name]: "",
    }));

    setMessage(null);
    setError(null);
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    if (!validate()) return;

    try {
      const response = await fetch("https://localhost:7178/api/Auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          username: formData.username,
          password: formData.password,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        setError(errorData.message || "Failed to register");
        return;
      }

      setMessage("Registration successful! You can now log in.");
      setFormData({ username: "", password: "", confirmPassword: "" });
    } catch {
      setError("Server error during registration");
    }
  };

  return (
    <div className="signup-container" style={{ maxWidth: 400, margin: "40px auto", padding: 20 }}>
      <h2>Sign Up</h2>

      {message && <p style={{ color: "green" }}>{message}</p>}
      {error && <p style={{ color: "red" }}>{error}</p>}

      <form onSubmit={handleSubmit} noValidate>
        <label htmlFor="username">Username</label>
        <input
          id="username"
          name="username"
          type="text"
          placeholder="Enter username"
          value={formData.username}
          onChange={handleChange}
          required
          autoComplete="username"
        />
        {errors.username && <p style={{ color: "red", marginTop: 0 }}>{errors.username}</p>}

        <label htmlFor="password">Password</label>
        <input
          id="password"
          name="password"
          type="password"
          placeholder="Enter password"
          value={formData.password}
          onChange={handleChange}
          required
          autoComplete="new-password"
        />
        {errors.password && <p style={{ color: "red", marginTop: 0 }}>{errors.password}</p>}

        <label htmlFor="confirmPassword">Confirm Password</label>
        <input
          id="confirmPassword"
          name="confirmPassword"
          type="password"
          placeholder="Confirm password"
          value={formData.confirmPassword}
          onChange={handleChange}
          required
          autoComplete="new-password"
        />
        {errors.confirmPassword && <p style={{ color: "red", marginTop: 0 }}>{errors.confirmPassword}</p>}

        <button
          type="submit"
          style={{ marginTop: 15, padding: "10px 0", width: "100%", cursor: "pointer" }}
        >
          Register
        </button>
      </form>
    </div>
  );
};

export default Signup;
