import Seller from "../models/seller.js"
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

const approveSeller = async (req, res) => {
  try {
   
    const { id } = req.params;

    const approvedSeller = await Seller.findByIdAndUpdate(
      id,
      { isVerified: true },
      { new: true } 
    );

    if (!approvedSeller) {
      return res.status(404).json({ 
        message: "Seller not found. Check the ID again." 
      });
    }

    res.status(200).json({
      message: "Business approved successfully!",
      data: approvedSeller
    });

  } catch (error) {
    res.status(500).json({ 
      message: "Server error during approval", 
      error: error.message 
    });
  }
};
   