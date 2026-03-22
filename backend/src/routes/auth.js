import express from "express";
import {
  login,
  register,
  forgotPassword,
  resetPassword,
  changePassword,
  showResetPasswordPage,
  googleAuth,
  getCurrentUser,
} from "../controller/userController.js";
import { verifyToken } from "../middleware/auth.js";

const authRouter = express.Router();

//Register
authRouter.post("/register", register);

//login
authRouter.post("/login", login);

//forgot password
authRouter.post("/forgotPassword", forgotPassword);

//forgot password
authRouter.post("/resetPassword/:token", resetPassword);

// change password for logged-in users
authRouter.post("/changePassword", verifyToken, changePassword);

authRouter.get("/resetPassword/:token", showResetPasswordPage);

authRouter.post('/googleAuth', googleAuth);

// Get current user details (requires authentication)
authRouter.get("/me", verifyToken, getCurrentUser);

export default authRouter;
