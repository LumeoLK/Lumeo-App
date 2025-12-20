import User from "../models/User.js";
import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import nodemailer from "nodemailer";

export const register = async (req, res) => {
  try {
    const { email, password, name } = req.body;
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res
        .status(400)
        .json({ msg: "User with same email already exist" });
    }
    const hashedPassword = await bcryptjs.hash(password, 8);
    let user = new User({ email, password: hashedPassword, name });
    user = await user.save();
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(400)
        .json({ msg: "User with this email does not exists" });
    }
    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Incorrect password" });
    }
    const token = jwt.sign({ id: user._id }, "passwordKey");
    res.json({ token, ...user._doc });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: "User not found" });
    }
    const token = jwt.sign({ email }, process.env.JWT_SECRET, {
      expiresIn: "15m",
    });
    const transporter = nodemailer.createTransport({
      service: "gmail",
      secure: true,
      auth: {
        user: process.env.EMAIL,
        pass: process.env.EMAIL_PASSWORD,
      },
    });
    const receiver = {
      from: process.env.EMAIL,
      to: email,
      subject: "Lumeo Password Reset Request",
      text: `Click on this link to reset your password ${process.env.CLIENT_URL}/resetPassword/${token}`,
    };
    await transporter.sendMail(receiver);
    return res.send({
      message: "Password reset sent successfully to your gmail account",
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ msg: "Internal server error" });
  }
};

export const showResetPasswordPage = async (req, res) => {
  res.sendFile("resetPassword.html", { root: "public" });
};

export const resetPassword = async (req, res) => {
  try {
    const { token } = req.params;
    const { password } = req.body;
    if (!password) {
      return res.status(400).json({ msg: "Please provide a password" });
    }
    const decode = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findOne({ email: decode.email });
    const newhashPassword = await bcryptjs.hash(password, 10);
    user.password = newhashPassword;
    await user.save();
    return res.status(200).send({ message: "Password reset successfully" });
  } catch (error) {
    return res.status(500).json({ msg: error.message });
  }
};

export const googleAuth = async (req, res) => {
  try {
    const { email, profilePicture, mode } = req.body;
    let user = await User.findOne({ email });
    if (mode === "login" && !user) {
      return res
        .status(400)
        .json({ msg: "Account does not exist. Please sign up first." });
    }
    if (mode === "register") {
      if (user) {
        return res
          .status(400)
          .json({ msg: "Account already exists. Please log in." });
      }

      user = new User({
        email,
        profilePicture,
      });

      await user.save();
    }

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });
    res.status(200).json({
      token,
      user,
    });
  } catch (error) {
    return res.status(500).json({ msg: error.message });
  }
};
