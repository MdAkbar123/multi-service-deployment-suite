const express = require("express");
const mongoose = require("mongoose");
const redis = require("redis");
const cors = require("cors");

const userRoutes = require("./routes/userRoutes");

const app = express();
app.use(express.json());
app.use(cors());

// ------------------------
// MongoDB Connection
// ------------------------
const MONGO_URI = process.env.MONGO_URI;
mongoose
  .connect(MONGO_URI)
  .then(() => console.log("✅ MongoDB connected"))
  .catch((err) => {
    console.error("❌ MongoDB connection error:", err);
    process.exit(1);
  });

  // Middleware
app.use(express.json());

// ------------------------
// Redis Connection
// ------------------------
const redisClient = redis.createClient({
  url: process.env.REDIS_URL,
});
redisClient
  .connect()
  .then(() => console.log("✅ Redis connected"))
  .catch((err) => {
    console.error("❌ Redis error:", err);
  });

// ------------------------
// Routes
// ------------------------
app.use("/api/users", userRoutes);

// Health endpoint for Docker
app.get("/health", (req, res) => res.json({ status: "healthy" }));

// Test API endpoint
app.get('/api/hello', (req, res) => {
  res.json({ msg: "Hello from Backend" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 API running on port ${PORT}`));


