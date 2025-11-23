import React, { useState, useEffect } from 'react';

function App() {
  const [message, setMessage] = useState('Loading...');

  useEffect(() => {
    fetch('/api/hello')
      .then(res => res.json())
      .then(data => setMessage(data.msg || 'Connected to API'))
      .catch(err => setMessage('API Connection Failed'));
  }, []);

  return (
    <div style={{ padding: '20px', fontFamily: 'sans-serif' }}>
      <h1>Microservices Frontend</h1>
      <p>Status: <strong>{message}</strong></p>
    </div>
  );
}

export default App;