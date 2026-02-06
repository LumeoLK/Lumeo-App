import Seller from "../models/seller.js";
export const becomeSeller = async (req, res) => {
  try {
    const { shopName, displayName, logo, businessAddress, phoneNumber, NICfront, NICback,businessRegNumber,password } = req.body;
    const existingSeller = await Seller.findOne({ businessRegNumber });
    if (existingSeller) {
      return res
        .status(400)
        .json({ msg: "Seller with same Business Registration Number already exist" });
    }
    const seller = new Seller({
      userId: req.user.id,
      shopName,
      displayName,
      logo,
      businessAddress,
      phoneNumber,
      NICfront,
      NICback,
      businessRegNumber
    });
    
    await seller.save();
    res.json({success: true, seller});
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
}