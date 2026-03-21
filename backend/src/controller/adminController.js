import Product from "../models/Product.js";
import Order from "../models/order.js";

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



//ORDER MANAGEMENT LOGIC

// @desc    Get all orders across the platform
// @route   GET /api/admin/orders
export const getAllOrders = async (req, res) => {
  try {
    // Populate the buyer's name/email AND the titles/images of the products they bought
    const orders = await Order.find({})
      .populate("buyerId", "name email") 
      .populate("items.productId", "title images price category")
      .populate("items.customRequestId", "title status") // Just in case it's a custom job
      .sort({ createdAt: -1 });

    res.status(200).json(orders);
  } catch (error) {
    console.error("Error fetching orders:", error);
    res.status(500).json({ message: "Server error while fetching orders." });
  }
};

// @desc    Update the fulfillment status of an order
// @route   PUT /api/admin/orders/:id/status
export const updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; 

    const validStatuses = ["pending", "processing", "shipped", "delivered", "cancelled"];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ message: "Invalid order status provided." });
    }

    const updatedOrder = await Order.findByIdAndUpdate(
      id,
      { status: status },
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(404).json({ message: "Order not found." });
    }

    res.status(200).json({ message: `Order status updated to ${status}`, order: updatedOrder });
  } catch (error) {
    console.error("Error updating order status:", error);
    res.status(500).json({ message: "Server error while updating order status." });
  }
};

// @desc    Update the payment status of an order (Great for COD)
// @route   PUT /api/admin/orders/:id/payment
export const updatePaymentStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { paymentStatus } = req.body; 

    const validStatuses = ["pending", "paid", "failed"];
    if (!validStatuses.includes(paymentStatus)) {
      return res.status(400).json({ message: "Invalid payment status provided." });
    }

    const updatedOrder = await Order.findByIdAndUpdate(
      id,
      { paymentStatus: paymentStatus },
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(404).json({ message: "Order not found." });
    }

    res.status(200).json({ message: `Payment marked as ${paymentStatus}`, order: updatedOrder });
  } catch (error) {
    console.error("Error updating payment status:", error);
    res.status(500).json({ message: "Server error while updating payment status." });
  }
};

// @desc    Delete an order entirely (Admin override)
// @route   DELETE /api/admin/orders/:id
export const deleteOrder = async (req, res) => {
  try {
    const { id } = req.params;

    const deletedOrder = await Order.findByIdAndDelete(id);

    if (!deletedOrder) {
      return res.status(404).json({ message: "Order not found." });
    }

    res.status(200).json({ message: "Order permanently deleted from the platform." });
  } catch (error) {
    console.error("Error deleting order:", error);
    res.status(500).json({ message: "Server error while deleting order." });
  }
};