import express from "express";
import {
  login,
  register,
  forgotPassword,
  resetPassword,
  showResetPasswordPage,googleAuth

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


authRouter.post('/googleAuth', googleAuth);

export default authRouter;
