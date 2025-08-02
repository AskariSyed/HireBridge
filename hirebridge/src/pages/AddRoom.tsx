import React, { useState, ChangeEvent, FormEvent } from "react";

const AddRoom: React.FC = () => {
  const [formData, setFormData] = useState({
    roomNumber: "",
    capacity: 1,
  });

  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === "capacity" ? parseInt(value) : value,
    }));
  };
const handleSubmit = async (e: FormEvent) => {
  e.preventDefault();
  setMessage(null);
  setError(null);

  const token = localStorage.getItem('token');

  try {
    const response = await fetch("https://localhost:7178/api/Room/add", {
      method: "POST",
      headers: { 
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`
      },
      body: JSON.stringify({
        RoomNumber: formData.roomNumber,
        Capacity: formData.capacity,
      }),
    });

   if (response.status === 401) {
  if (window.confirm('Session expired. Please login again.')) {
    localStorage.removeItem('token');
    window.location.href = '/login';
  }
  return;
}


    if (!response.ok) {
      setError("Failed to add room");
      return;
    }

    const data = await response.json();
    setMessage(`Room added successfully! Room Number: ${data.roomNumber}`);
    setFormData({ roomNumber: "", capacity: 1 });
  } catch {
    setError("Server error while adding room");
  }
};
  return (
    <div>
      <h2>Add Room</h2>
      {message && <p style={{ color: "green" }}>{message}</p>}
      {error && <p style={{ color: "red" }}>{error}</p>}

      <form onSubmit={handleSubmit}>
        <input
          type="text"
          name="roomNumber"
          placeholder="Room Number"
          value={formData.roomNumber}
          onChange={handleChange}
          required
        /><br />

        <input
          type="number"
          name="capacity"
          placeholder="Capacity"
          value={formData.capacity}
          onChange={handleChange}
          required
        /><br />

        <button type="submit">Add Room</button>
      </form>
    </div>
  );
};

export default AddRoom;
