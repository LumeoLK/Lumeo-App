import request from "supertest";
import app from "../src/index.js"; // Importing the app we just exported!

describe("Sanity Check Tests", () => {
  // This is a single unit test
  it("should return 200 OK from the /api/health endpoint", async () => {
    // 1. Arrange & Act: Supertest makes a fake GET request to your app
    const response = await request(app).get("/api/health");

    // 2. Assert: We check if the response is exactly what we expect
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: "ok" });
  });
});
