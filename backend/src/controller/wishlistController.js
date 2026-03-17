import Wishlist from "../models/wishlist.js";
import Product from "../models/Product.js";

// Get User's Wishlist
export const getWishlist = async (req, res) => {
    try {
        // req.user.id comes from verifyToken (JWT payload has { id: user._id })
        let wishlist = await Wishlist.findOne({ userId: req.user.id }).populate("products");

        if (!wishlist) {
            return res.json({ products: [] });
        }

        res.json(wishlist);
    } catch (error) {
        res.status(500).json({ msg: error.message });
    }
};

// Remove Item from Wishlist
export const removeFromWishlist = async (req, res) => {
    try {
        const { productId } = req.body;

        let wishlist = await Wishlist.findOneAndUpdate(
            { userId: req.user.id },
            { $pull: { products: productId } },
            { new: true }
        ).populate("products");

        if (!wishlist) return res.status(404).json({ msg: "Wishlist not found" });

        res.json(wishlist);
    } catch (error) {
        res.status(500).json({ msg: error.message });
    }
};

// Add Item to Wishlist
export const addToWishlist = async (req, res) => {
    try {
        const { productId } = req.body;

        // Validate that the product actually exists before adding it
        const product = await Product.findById(productId);
        if (!product) return res.status(404).json({ msg: "Product not found" });

        let wishlist = await Wishlist.findOneAndUpdate(
            { userId: req.user.id },
            { $addToSet: { products: productId } },
            { new: true, upsert: true }
        ).populate("products");

        res.status(200).json(wishlist);
    } catch (error) {
        res.status(500).json({ msg: error.message });
    }
};
