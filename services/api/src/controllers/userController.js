const User = require("../models/userModel");

// GET /api/users
exports.getUsers = async (req, res) => {
  try {
    const users = await User.find({});
    res.json({ success: true, users });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};

// POST /api/users
exports.createUser = async (req, res) => {
  try {
    const user = new User({
      name: req.body.name,
      email: req.body.email,
    });

    await user.save();
    res.json({ success: true, message: "User created", user });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};
