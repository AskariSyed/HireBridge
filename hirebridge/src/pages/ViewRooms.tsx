import React, { useEffect, useState } from "react";
import "../css/ViewAllRooms.css";

type Company = {
  id: number;
  name: string;
};

type Room = {
  id: number;
  roomNumber: string;
  capacity: number;
  isOccupied: boolean;
  company: Company | null;
};

function ViewAllRooms() {
  const [rooms, setRooms] = useState<Room[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchRooms();
  }, []);
const fetchRooms = async () => {
  setLoading(true);
  setError(null);

  const token = localStorage.getItem('token');

  try {
    const response = await fetch("https://localhost:7178/api/Room/all", {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.status === 401) {
      setError('Session expired. Please login again.');
      localStorage.removeItem('token');
      // Redirect to login page after a short delay to show error
      setTimeout(() => {
        window.location.href = '/login';
      }, 2000);
      return;
    }

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(errorText || "Failed to fetch rooms");
    }

    const data: Room[] = await response.json();
    setRooms(data);
  } catch (err: any) {
    console.error(err);
    setError(err.message || "An error occurred while fetching rooms");
  } finally {
    setLoading(false);
  }
};

  return (
    <div className="view-all-rooms-container">
      <h2>All Rooms</h2>

      {loading && <p>Loading rooms...</p>}
      {error && <p style={{ color: "red" }}>{error}</p>}

      {!loading && rooms.length === 0 && <p>No rooms found.</p>}

      {!loading && rooms.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>Room ID</th>
              <th>Room Number</th>
              <th>Capacity</th>
              <th>Occupied</th>
              <th>Company</th>
            </tr>
          </thead>
          <tbody>
            {rooms.map((room) => (
              <tr key={room.id}>
                <td>{room.id}</td>
                <td>{room.roomNumber}</td>
                <td>{room.capacity}</td>
                <td>{room.isOccupied ? "Yes" : "No"}</td>
                <td>{room.company ? room.company.name : "Unassigned"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default ViewAllRooms;
