import mongoose from "mongoose";
import dotenv from "dotenv";
import User from "./models/User.js"; // Adjust this path to where your User model file is!

dotenv.config();

const testConnection = async () => {
  try {
    // 1. Connect to MongoDB
    console.log("⏳ Connecting to MongoDB...");
    await mongoose.connect(process.env.MONGODB_URL);
    console.log("✅ Connected successfully!");

    // 2. Create a dummy user
    const testUser = new User({
      name: "Test User",
      email: `test${Date.now()}@example.com`, // Unique email every time to prevent conflicts
      password: "password123",
      googleId: `google_id_${Date.now()}`,
    });

    // 3. Save to Database
    console.log("⏳ Saving user...");
    const savedUser = await testUser.save();
    
    console.log("🎉 User saved successfully!");
    console.log(savedUser);

  } catch (error) {
    console.error("❌ Error:", error.message);
  } finally {
    // 4. Close connection
    mongoose.connection.close();
    console.log("🔌 Connection closed.");
  }
};

export default testConnection;