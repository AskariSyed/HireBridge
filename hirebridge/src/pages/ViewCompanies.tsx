import React, { useEffect, useState } from "react";
import "../css/ViewAllCompanies.css";

type Company = {
  companyId: number;
  companyName: string;
  username: string;
  hrContact: string;
  domain: string;
  numReps: number;
  roomNumber: string;
  estimatedinterviewDuration: number;
};

function ViewAllCompanies() {
  const [companies, setCompanies] = useState<Company[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [filterAssigned, setFilterAssigned] = useState<string>("all");

  useEffect(() => {
    fetchCompanies();
  }, [filterAssigned]);
const fetchCompanies = async () => {
  setLoading(true);
  setError(null);

  const token = localStorage.getItem('token');

  try {
    let url = "https://localhost:7178/api/Company/all";

    if (filterAssigned === "assigned") {
      url = "https://localhost:7178/api/Company/filter?isAssigned=true";
    } else if (filterAssigned === "unassigned") {
      url = "https://localhost:7178/api/Company/filter?isAssigned=false";
    }

    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.status === 401) {
      setError('Session expired. Please login again.');
      localStorage.removeItem('token');
      setTimeout(() => {
        window.location.href = '/login';
      }, 2000);
      return;
    }

    if (!response.ok) {
      throw new Error(`Failed to fetch companies: ${response.status}`);
    }

    const data = await response.json();
    setCompanies(data);
  } catch (err: any) {
    console.error(err);
    setError(err.message || "Error fetching companies.");
  } finally {
    setLoading(false);
  }
};
  const handleFilterChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setFilterAssigned(e.target.value);
  };

  return (
    <div className="view-all-companies-container">
      <h2>All Companies</h2>

      <div>
        <label>Filter by Room Assignment: </label>
        <select value={filterAssigned} onChange={handleFilterChange}>
          <option value="all">All</option>
          <option value="assigned">Assigned</option>
          <option value="unassigned">Unassigned</option>
        </select>
      </div>

      {loading && <p>Loading companies...</p>}
      {error && <p style={{ color: "red" }}>{error}</p>}

      {!loading && companies.length === 0 && <p>No companies found.</p>}

      {!loading && companies.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>Company ID</th>
              <th>Company Name</th>
              <th>Username</th>
              <th>HR Contact</th>
              <th>Domain</th>
              <th>Number of Reps</th>
              <th>Room Number</th>
              <th>Estimated Interview Duration</th>
            </tr>
          </thead>
          <tbody>
            {companies.map((company) => (
              <tr key={company.companyId}>
                <td>{company.companyId}</td>
                <td>{company.companyName}</td>
                <td>{company.username}</td>
                <td>{company.hrContact}</td>
                <td>{company.domain}</td>
                <td>{company.numReps}</td>
                <td>{company.roomNumber}</td>
                <td>{company.estimatedinterviewDuration}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default ViewAllCompanies;
