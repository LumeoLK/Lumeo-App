import Wishlist from "../models/wishlist.js";
import Product from "../models/Product.js";

// Get User's Wishlist
export const getWishlist = async (req, res) => {
    try {
        // Find the wishlist by req.user._id and return the products
        let wishlist = await Wishlist.findOne({ user: req.user._id }).populate("products");

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
            { user: req.user._id },
            { $pull: { products: productId } },
            { new: true } // Return updated wishlist
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
            { user: req.user._id },
            { $addToSet: { products: productId } },
            { new: true, upsert: true } // Upsert creates the document if it doesn't exist
        ).populate("products");

        res.status(200).json(wishlist);
    } catch (error) {
        res.status(500).json({ msg: error.message });
    }
};
