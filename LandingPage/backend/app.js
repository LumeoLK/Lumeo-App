import express from "express";
import cors from "cors";
import nodemailer from "nodemailer";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const port = 5000;

app.use(cors());
app.use(express.json());

function sendEmail({ email, subject, message }) {
  return new Promise((resolve, reject) => {
    if (!process.env.EMAIL || !process.env.EMAIL_PASSWORD) {
      return reject({ message: "Credentials missing from .env" });
    }

    var transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL,
        pass: process.env.EMAIL_PASSWORD,
      },
    });

    const mail_configs = {
      from: process.env.EMAIL,
      to: email,
      subject: subject,
      text: message,
    };

    transporter.sendMail(mail_configs, function (error, info) {
      if (error) {
        return reject({ message: error.message });
      }

      return resolve({ message: "Email sent successfully" });
    });
  });
}

app.get("/", (req, res) => {
  console.log("Request received:", req.query);

  sendEmail(req.query)
    .then((response) => {
      res.send(response.message);
    })
    .catch((error) => {
      console.error("Request failed");
      res.status(500).send(error.message);
    });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
