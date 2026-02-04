import mongoose from "mongoose";

const userSchema = mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },
  email: {
    type: String,
    required: true,
    unique: true, 
    lowercase: true,
    validate: {
      validator: (value) => {
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return value.match(regex);
      },
      message: "Please enter a valid email address",
    },
  },
  password: {
    type: String,
    required: function() { 
       
        return !this.googleId; 
    }, 
  },

  role: {
    type: String,
    enum: ["user", "seller", "admin"], 
    default: "user",
  },

  googleId: {
    type: String,
    unique: true,
    sparse: true, 
  },
  profilePicture: {
    type: String,
    default: "",
  },
  isEmailVerified: {
    type: Boolean,
    default: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const User = mongoose.model("User", userSchema);
export default User;