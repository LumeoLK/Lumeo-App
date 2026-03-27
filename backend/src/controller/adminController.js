import bcryptjs from "bcryptjs";
import User from "../models/User.js";
import Seller from "../models/seller.js";
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
   
//SELLER VERIFICATION LOGIC

// @desc    Get all pending seller applications
// @route   GET /api/admin/sellers/pending
export const getPendingSellers = async (req, res) => {
  try {
    const pendingSellers = await Seller.find({ isVerified: false })
      .populate("userId", "name email") 
      .sort({ createdAt: -1 });
    res.status(200).json(pendingSellers);
  } catch (error) {
    console.error("Error fetching pending sellers:", error);
    res.status(500).json({ message: "Server error while fetching sellers." });
  }
};

// @desc    Approve a seller application
// @route   PUT /api/admin/sellers/:id/approve
export const approveSeller = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedSeller = await Seller.findByIdAndUpdate(
      id,
      { isVerified: true },
      { new: true } 
    );
    if (!updatedSeller) {
      return res.status(404).json({ message: "Seller application not found." });
    }
    res.status(200).json({ message: "Seller approved successfully!", seller: updatedSeller });
  } catch (error) {
    console.error("Error approving seller:", error);
    res.status(500).json({ message: "Server error while approving seller." });
  }
};

// @desc    Reject and delete a seller application
// @route   DELETE /api/admin/sellers/:id/reject
export const rejectSeller = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedSeller = await Seller.findByIdAndDelete(id);
    if (!deletedSeller) {
      return res.status(404).json({ message: "Seller application not found." });
    }
    res.status(200).json({ message: "Seller application rejected." });
  } catch (error) {
    console.error("Error rejecting seller:", error);
    res.status(500).json({ message: "Server error while rejecting seller." });
  }
};

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


//DASHBOARD ANALYTICS LOGIC

// @desc    Get aggregate stats for the main admin dashboard
// @route   GET /api/admin/dashboard-stats
export const getDashboardStats = async (req, res) => {
  try {
    // 1. Calculate Total Revenue (Sum of all orders that aren't cancelled)
    const revenueResult = await Order.aggregate([
      { $match: { status: { $ne: "cancelled" } } },
      { $group: { _id: null, total: { $sum: "$totalAmount" } } }
    ]);
    const totalRevenue = revenueResult.length > 0 ? revenueResult[0].total : 0;

    // 2. Count Total Users (Assuming standard buyers/customers)
    const totalUsers = await User.countDocuments({ role: { $ne: "admin" } });

    // 3. Count Active Sellers (Approved shops)
    const activeSellers = await Seller.countDocuments({ isVerified: true });

    // 4. Count Pending Seller Requests
    const pendingRequests = await Seller.countDocuments({ isVerified: false });

    // Send it all back in one neat package
    res.status(200).json({
      totalRevenue,
      totalUsers,
      activeSellers,
      pendingRequests
    });

  } catch (error) {
    console.error("Error fetching dashboard stats:", error);
    res.status(500).json({ message: "Server error while fetching dashboard stats." });
  }
};


// @desc    Get revenue data for the chart (Last 7 Days)
// @route   GET /api/admin/revenue-chart
export const getRevenueChartData = async (req, res) => {
  try {
    // 1. Get the date for exactly 7 days ago
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    // 2. Aggregate the data
    const revenueData = await Order.aggregate([
      // Match only valid orders from the last 7 days
      {
        $match: {
          status: { $ne: "cancelled" },
          createdAt: { $gte: sevenDaysAgo }
        }
      },
      // Group them by the date string (YYYY-MM-DD) and sum the totalAmount
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
          revenue: { $sum: "$totalAmount" }
        }
      },
      // Sort them chronologically
      { $sort: { _id: 1 } } 
    ]);

    res.status(200).json(revenueData);
  } catch (error) {
    console.error("Error fetching chart data:", error);
    res.status(500).json({ message: "Server error fetching chart data." });
  }
};

// @desc    Get system settings
// @route   GET /api/admin/settings
export const getSettings = async (req, res) => {
  try {
    // TODO: Implement settings model/database query
    // For now, return default settings
    const settings = {
      id: "default",
      siteName: "Lumeo",
      maintenanceMode: false,
      maxUploadSize: 10, // MB
      enableUserRegistration: true,
      enableSellerRegistration: true,
      commissionRate: 0.1, // 10%
      currency: "USD"
    };
    res.status(200).json(settings);
  } catch (error) {
    console.error("Error fetching settings:", error);
    res.status(500).json({ message: "Server error fetching settings." });
  }
};

// @desc    Update system settings
// @route   PUT /api/admin/settings
export const updateSettings = async (req, res) => {
  try {
    const { siteName, maintenanceMode, maxUploadSize, enableUserRegistration, enableSellerRegistration, commissionRate, currency } = req.body;
    
    // TODO: Implement settings model/database update
    // For now, return updated settings
    const updatedSettings = {
      id: "default",
      siteName: siteName || "Lumeo",
      maintenanceMode: maintenanceMode || false,
      maxUploadSize: maxUploadSize || 10,
      enableUserRegistration: enableUserRegistration !== undefined ? enableUserRegistration : true,
      enableSellerRegistration: enableSellerRegistration !== undefined ? enableSellerRegistration : true,
      commissionRate: commissionRate || 0.1,
      currency: currency || "USD"
    };
    
    res.status(200).json({ message: "Settings updated successfully", settings: updatedSettings });
  } catch (error) {
    console.error("Error updating settings:", error);
    res.status(500).json({ message: "Server error updating settings." });
  }
};