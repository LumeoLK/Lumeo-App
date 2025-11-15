import express from "express";
import cors from "cors";
import nodemailer from "nodemailer";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const port = 5000;

app.use(cors());
app.use(express.json());

async function sendEmail({ email, subject, message }) {
  if (!process.env.EMAIL || !process.env.EMAIL_PASSWORD) {
    throw new Error("Credentials missing from .env");
  }

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.EMAIL,
      pass: process.env.EMAIL_PASSWORD,
    },
  });

  // Email sent to the user
  const mail_to_user = {
    from: process.env.EMAIL,
    to: email,
    subject: "Thank you for your response",
    text: "Thank you for your response. Will get back to you soon",
  };

  // Email sent to the owner
  const mail_to_owner = {
    from: process.env.EMAIL,
    to: process.env.EMAIL_OWNER1,
    subject: "New Response - HIVE",
    text: `Email: ${email}\nMessage: ${message}`,
  };

  // Send email to user
  await transporter.sendMail(mail_to_user);

  // Send email to owner
  await transporter.sendMail(mail_to_owner);

  return "Emails sent successfully";
}

// POST route to send email
app.post("/send-email", async (req, res) => {
  try {
    const result = await sendEmail(req.body);
    res.status(200).json({ message: result });
  } catch (error) {
    console.error("Email sending failed:", error.message);
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
