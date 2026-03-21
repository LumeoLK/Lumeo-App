import Product from "../models/Product.js";

export async function adminRegister() {
    const existingAdmin = await User.findOne({ email: "admin@lumeo.com" });
        if (existingAdmin) {
            console.log("Admin already exists");
            process.exit();
        }
    
        const hashedPassword = await bcryptjs.hash("admin123", 10);
    
        const admin = new User({
            name: "Super Admin",
            email: "admin@lumeo.com",
            password: hashedPassword,
            role: "admin" 
        });
    
        await admin.save();
        console.log("Admin created successfully!");
}
   

// @desc    Get all products across the platform (Includes AR model data)
// @route   GET /api/admin/products
export const getAllProducts = async (req, res) => {
  try {
    // Populate pulls the Shop Name and Email from the connected Seller document
    const products = await Product.find({})
      .populate("sellerId", "shopName email") 
      .sort({ createdAt: -1 });

    res.status(200).json(products);
  } catch (error) {
    console.error("Error fetching products:", error);
    res.status(500).json({ message: "Server error while fetching products." });
  }
};

// @desc    Delete a product (Admin override for rule violations)
// @route   DELETE /api/admin/products/:id
export const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const deletedProduct = await Product.findByIdAndDelete(id);

    if (!deletedProduct) {
      return res.status(404).json({ message: "Product not found." });
    }

    res.status(200).json({ message: "Product permanently deleted from the platform." });
  } catch (error) {
    console.error("Error deleting product:", error);
    res.status(500).json({ message: "Server error while deleting product." });
  }
};

// @desc    Update the 3D Model status of a product (Approve/Reject AR asset)
// @route   PUT /api/admin/products/:id/model-status
export const updateModelStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; 

    // Validate the status against your Product schema's exact enum values
    const validStatuses = ["pending", "approved", "failed", "generating", "success"];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ message: "Invalid status provided." });
    }

    // Update only the specific nested 'model3D.status' field
    const updatedProduct = await Product.findByIdAndUpdate(
      id,
      { $set: { "model3D.status": status } },
      { new: true }
    );

    if (!updatedProduct) {
      return res.status(404).json({ message: "Product not found." });
    }

    res.status(200).json({ 
      message: `3D Model status updated to ${status}`, 
      product: updatedProduct 
    });
  } catch (error) {
    console.error("Error updating model status:", error);
    res.status(500).json({ message: "Server error while updating model status." });
  }
};