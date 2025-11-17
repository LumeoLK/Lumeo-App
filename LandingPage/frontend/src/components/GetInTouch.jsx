import React, { useState } from "react";
import axios from "axios";
import { Button, Label, TextInput, Textarea } from "flowbite-react";

const GetInToch = () => {
  const [email, setEmail] = useState("");
  const [name, setName] = useState("");
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");

  const sendMail = async (e) => {
    e.preventDefault();

    try {
      await axios.post("http://localhost:5000/send-email", {
        email,
        name,
        subject,
        message,
      });

      alert("Email sent successfully!");

      // optional: clear fields after sending
      setEmail("");
      setName("");
      setSubject("");
      setMessage("");
    } catch (err) {
      console.error("Error sending email:", err);
      alert("Failed to send email.");
    }
  };

  return (
    <form
      onSubmit={sendMail}
      className="w-full max-w-sm sm:max-w-md md:max-w-lg lg:max-w-xl xl:max-w-2xl 
             bg-amber-400 p-4 sm:p-6 md:p-8 
             rounded-xl mx-auto flex flex-col gap-4"
    >
      <h1 className="font-bold text-3xl">Get In Touch </h1>
      <div>
        <Label htmlFor="input-name" color="gray" className="mb-2 block">
          Name
        </Label>
        <TextInput
          id="input-name"
          placeholder="Name"
          required
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
      </div>

      <div>
        <Label htmlFor="email1" className="mb-2 block ">
          Your email
        </Label>
        <TextInput
          id="email1"
          type="email"
          placeholder="name@example.com"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
      </div>

      <div>
        <Label htmlFor="input-subject" color="gray" className="mb-2 block">
          Subject
        </Label>
        <TextInput
          id="input-subject"
          placeholder="Subject"
          required
          value={subject}
          onChange={(e) => setSubject(e.target.value)}
        />
      </div>

      <div>
        <Label htmlFor="comment" className="mb-2 block">
          Your message
        </Label>
        <Textarea
          id="comment"
          placeholder="Leave a comment..."
          rows={4}
          required
          value={message}
          onChange={(e) => setMessage(e.target.value)}
        />
      </div>

      <Button type="submit" color="gray">
        Submit
      </Button>
    </form>
  );
};

export default GetInToch;
