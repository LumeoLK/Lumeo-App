import request from "supertest";
import app from "../src/index.js";
import Product from "../src/models/Product.js";
import { jest } from "@jest/globals";

describe("Product CRUD API Tests", () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("should fetch a list of products (READ)", async () => {
    //  Create fake data
    const fakeProducts = [
      { _id: "123", name: "Luxury Chair", price: 150 },
      { _id: "456", name: "Oak Table", price: 300 },
    ];
    const mockQuery = {
      populate: jest.fn().mockReturnThis(),
      sort: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      skip: jest.fn().mockReturnThis(),
      lean: jest.fn().mockReturnThis(),
      exec: jest.fn().mockResolvedValue(fakeProducts),
      then: function (resolve) {
        resolve(fakeProducts);
      },
    };

    jest.spyOn(Product, "find").mockReturnValue(mockQuery);

    const response = await request(app).get("/api/products");

    // 4. Assert: Check if backend handled it correctly
    expect(response.status).toBe(200);
    expect(response.body).toBeDefined();

    // Prove the database method was actually called
    expect(Product.find).toHaveBeenCalledTimes(1);
  });
});
