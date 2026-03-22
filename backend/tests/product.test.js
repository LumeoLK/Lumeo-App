import request from "supertest";
import app from "../src/index.js";
import Product from "../src/models/Product.js";
import { jest } from "@jest/globals";

describe("Product CRUD API Tests", () => {
  // This cleans up our "Spies" after each test so they don't leak
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("should fetch a list of products (READ)", async () => {
    // 1. Arrange: Create our fake data
    const fakeProducts = [
      { _id: "123", name: "Luxury Chair", price: 150 },
      { _id: "456", name: "Oak Table", price: 300 },
    ];

    // 2. The Upgraded ESM-Friendly Mock: Handle Chained Mongoose Methods!
    const mockQuery = {
      populate: jest.fn().mockReturnThis(),
      sort: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      skip: jest.fn().mockReturnThis(),
      lean: jest.fn().mockReturnThis(),
      // The final command that actually returns the data
      exec: jest.fn().mockResolvedValue(fakeProducts),
      // Fallback in case your controller uses .then instead of .exec
      then: function (resolve) {
        resolve(fakeProducts);
      },
    };

    jest.spyOn(Product, "find").mockReturnValue(mockQuery);

    // 3. Act: Make the fake request to your route
    const response = await request(app).get("/api/products");

    // 4. Assert: Check if your backend handled it correctly
    expect(response.status).toBe(200);
    expect(response.body).toBeDefined();

    // Prove the database method was actually called!
    expect(Product.find).toHaveBeenCalledTimes(1);
  });
});
