import Review from "../models/review.js";
import Product from "../models/Product.js";
import Order from "../models/Order.js"; // Optional: To check if they bought it

export const addReview = async (req, res) => {
  try {
    const { productId, rating, comment } = req.body;
    const userId = req.user.id;

    // 1. Check if Product exists
    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ msg: "Product not found" });

    // 2. (Optional but Recommended) Verified Purchase Check
    // We check if this user actually has a DELIVERED order for this item
    /* const hasBought = await Order.findOne({ 
      buyerId: userId, 
      "items.productId": productId, 
      status: "delivered" 
    });
    if (!hasBought) {
      return res.status(400).json({ msg: "You can only review items you have bought." });
    }
    */

    // 3. Create Review
    // If they already reviewed, the unique index in Model will throw an error
    const review = await Review.create({
      userId,
      productId,
      rating,
      comment
    });

    // 4. THE SMART PART: Recalculate Average Rating
    // We get all reviews for this product to find the new average
    const stats = await Review.aggregate([
      { $match: { productId: product._id } },
      {
        $group: {
          _id: "$productId",
          avgRating: { $avg: "$rating" }, // Calculate Average
          numReviews: { $sum: 1 }         // Count Total
        }
      }
    ]);

    // 5. Update Product with new stats
    if (stats.length > 0) {
      product.averageRating = stats[0].avgRating;
      product.numReviews = stats[0].numReviews;
      await product.save();
    }

    res.status(201).json({ success: true, review, newAverage: product.averageRating });

  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ msg: "You have already reviewed this product" });
    }
    res.status(500).json({ msg: error.message });
  }
};

// Get Reviews for a Product
export const getProductReviews = async (req, res) => {
  try {
    const reviews = await Review.find({ productId: req.params.productId })
      .populate("userId", "name profilePicture") // Show reviewer name
      .sort({ createdAt: -1 });
      
    res.json(reviews);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};