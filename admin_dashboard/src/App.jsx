import { useState, useEffect } from 'react';

function App() {
  const [bookings, setBookings] = useState([]);

  useEffect(() => {
    fetch('http://127.0.0.1:8000/bookings')
      .then((response) => response.json())
      .then((data) => setBookings(data));
  }, []);

  return (
    <div style={{ padding: '20px', fontFamily: 'sans-serif' }}>
      <h1>Admin Dashboard</h1>
      <h2>All Bookings</h2>
      <table border="1" cellPadding="8" style={{ borderCollapse: 'collapse' }}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Customer</th>
            <th>Service ID</th>
            <th>Status</th>
            <th>Created At</th>
          </tr>
        </thead>
        <tbody>
          {bookings.map((booking) => (
            <tr key={booking.id}>
              <td>{booking.id}</td>
              <td>{booking.customer_name}</td>
              <td>{booking.service_id}</td>
              <td>{booking.status}</td>
              <td>{booking.created_at}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default App;