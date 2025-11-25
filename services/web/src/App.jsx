import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [users, setUsers] = useState([]);
  const [source, setSource] = useState('Loading...');
  const [formData, setFormData] = useState({ name: '', email: '', role: 'Developer' });
  const [loading, setLoading] = useState(false);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const res = await fetch('/api/users');
      const data = await res.json();
      setUsers(data.data || []);
      setSource(data.source || 'API');
    } catch (err) {
      console.error(err);
      setSource('Connection Failed');
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    await fetch('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData),
    });
    setFormData({ name: '', email: '', role: 'Developer' });
    fetchUsers(); // Refresh list
  };

  return (
    <div className="container">
      <header className="header">
        <h1>🚀 Microservices Dashboard</h1>
        <div className="status-badge">
          Last Fetch Source: <strong>{source}</strong>
        </div>
      </header>

      <div className="grid">
        {/* Form Section */}
        <div className="card">
          <h2>Add New User</h2>
          <form onSubmit={handleSubmit}>
            <input
              type="text"
              placeholder="Name"
              value={formData.name}
              onChange={e => setFormData({...formData, name: e.target.value})}
              required
            />
            <input
              type="email"
              placeholder="Email"
              value={formData.email}
              onChange={e => setFormData({...formData, email: e.target.value})}
              required
            />
            <select 
              value={formData.role}
              onChange={e => setFormData({...formData, role: e.target.value})}
            >
              <option>Developer</option>
              <option>DevOps Engineer</option>
              <option>Manager</option>
            </select>
            <button type="submit" disabled={loading}>
              {loading ? 'Processing...' : 'Add to MongoDB'}
            </button>
          </form>
        </div>

        {/* List Section */}
        <div className="card">
          <div className="card-header">
            <h2>User Registry</h2>
            <button onClick={fetchUsers} className="refresh-btn">🔄 Refresh</button>
          </div>
          
          {users.length === 0 ? (
            <p className="empty-state">No users found in Database.</p>
          ) : (
            <ul className="user-list">
              {users.map((user) => (
                <li key={user._id} className="user-item">
                  <div className="user-info">
                    <strong>{user.name}</strong>
                    <span>{user.role}</span>
                  </div>
                  <small>{user.email}</small>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;