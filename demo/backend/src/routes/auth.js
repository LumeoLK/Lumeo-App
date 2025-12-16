import express from "express";
import {
  login,
  register,
  forgotPassword,
  resetPassword,
  showResetPasswordPage,authMiddleware,googleAuth, getCurrentUser

} from "../controller/userController.js";

const authRouter = express.Router();

//Register
authRouter.post("/register", register);

//login
authRouter.post("/login", login);

//forgot password
authRouter.post("/forgotPassword", forgotPassword);

//forgot password
authRouter.post("/resetPassword/:token", resetPassword);

authRouter.get("/resetPassword/:token", showResetPasswordPage);


authRouter.post('/google', googleAuth);
authRouter.get('/me', authMiddleware, getCurrentUser);
export default authRouter;
