import User from "../models/User.js";
import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import nodemailer from "nodemailer";
import { OAuth2Client } from "google-auth-library";

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

const user = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export const googleAuth = async (req, res) => {
  try {
    const { tokenID } = req.body;

    if (!tokenID) {
      return res.status(400).json({ msg: "ID token is required" });
    }
    const verifiedToken = await user.verifiedIDToken({
      tokenID,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = verifiedToken.getPayload();
    if (!payload) {
      return res.status(400).json({ msg: "Invalid google token" });
    }
    const { sub: googleId, email, name, picture, verified_email } = payload;

    if (!verified_email) {
      return res.status(400).json({ msg: "Google mail is not verified" });
    }
    const user = await User.findOne({ email });
    if (user) {
      if (!user.googleId) {
        user.googleId = googleId;
        user.profilePicture = picture || user.profilePicture;
        await user.save();
      }
    }
    user = new User({
      email,
      name,
      googleId,
      profilePicture: picture,
      isEmailVerified: true,
    });
    await user.save();

    const token = jwt.sign(
      { id: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    return res.status(200).json({
      message: "Google authentication successful",
      token,
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        profilePicture: user.profilePicture,
      },
    });
  } catch (error) {
    console.error("Google Auth Error:", error);
    return res.status(500).json({
      msg: "Google authentication failed",
      error: error.message,
    });
  }
};

export const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ msg: "No token, authorization denied" });
    }

    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ msg: "Token is not valid" });
  }
};

export const getCurrentUser = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    return res.status(200).json({
      id: user._id,
      email: user.email,
      name: user.name,
      profilePicture: user.profilePicture,
    });
  } catch (error) {
    return res.status(500).json({ msg: "Server error" });
  }
};
