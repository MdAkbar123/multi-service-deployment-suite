const User = require('../models/userModel');
const { createClient } = require('redis');

// Initialize Redis Client
const redisClient = createClient({
  url: 'redis://redis:6379'
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));
redisClient.connect();

exports.getUsers = async (req, res) => {
  try {
    // 1. Check Redis Cache
    const cacheKey = 'all_users';
    const cachedData = await redisClient.get(cacheKey);

    if (cachedData) {
      console.log('⚡ Serving from Redis Cache');
      return res.json({ 
        source: 'Redis Cache ⚡', 
        data: JSON.parse(cachedData) 
      });
    }

    // 2. If not in cache, get from MongoDB
    console.log('🐢 Serving from MongoDB');
    const users = await User.find().sort({ createdAt: -1 });

    // 3. Save to Redis (expire in 60 seconds)
    await redisClient.set(cacheKey, JSON.stringify(users), { EX: 60 });

    res.json({ 
      source: 'MongoDB 🐢', 
      data: users 
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createUser = async (req, res) => {
  try {
    const { name, email, role } = req.body;
    const newUser = new User({ name, email, role });
    await newUser.save();

    // 4. Invalidate Cache so next fetch gets fresh data
    await redisClient.del('all_users');

    res.status(201).json(newUser);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};