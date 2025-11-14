import React, { useState } from "react";
import axios from "axios";
import { Button, Label, TextInput, Textarea } from "flowbite-react";
const GetInToch = () => {
  const [email, setEmail] = useState("");
  const [name, setName] = useState("");
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");

  const sendMail = (e) => {
    e.preventDefault(); // Add this!
    axios
      .get("http://localhost:5000/", {
        params: { email, subject, message, name },
      })
      .then(() => {
        console.log("success");
        alert("Email sent successfully!");
      })
      .catch((err) => {
        console.log("Error", err);
        alert("Failed to send email", err);
      });
  };

  return (
    <form className="flex max-w-md flex-col gap-4 bg-amber-400 p-5">
      <div>
        <div className="mb-2 block">
          <Label htmlFor="input-name" color="gray">
            Name
          </Label>
        </div>
        <TextInput
          id="input-name"
          placeholder="Name"
          required
          color="gray"
          onChange={(e) => setName(e.target.value)}
        />
      </div>
      <div>
        <div className="mb-2 block">
          <Label htmlFor="email1">Your email</Label>
        </div>
        <TextInput
          id="email1"
          type="email"
          placeholder="name@flowbite.com"
          required
          onChange={(e) => setEmail(e.target.value)}
        />
      </div>
      <div>
        <div className="mb-2 block">
          <Label htmlFor="input-subject" color="gray">
            Subject of your message
          </Label>
        </div>
        <TextInput
          id="input-subject"
          placeholder="Subject "
          required
          color="gray"
          onChange={(e) => setSubject(e.target.value)}
        />
      </div>

      <div className="max-w-md">
        <div className="mb-2 block">
          <Label htmlFor="comment">Your message</Label>
        </div>
        <Textarea
          id="comment"
          placeholder="Leave a comment..."
          required
          rows={4}
          onChange={(e) => setMessage(e.target.value)}
        />
      </div>
      <Button type="submit" color="gray" onClick={sendMail}>
        Submit
      </Button>
    </form>
  );
};

export default GetInToch;
