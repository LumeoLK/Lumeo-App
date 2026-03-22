import PlatformSettings from "../models/PlatformSettings.js";

// @desc    Get global platform settings
// @route   GET /api/admin/settings
export const getSettings = async (req, res) => {
  try {
    let settings = await PlatformSettings.findOne();
    
    // If no settings exist in the DB yet, create a default one automatically
    if (!settings) {
      settings = await PlatformSettings.create({});
    }
    
    res.status(200).json(settings);
  } catch (error) {
    console.error("Error fetching settings:", error);
    res.status(500).json({ message: "Server error while fetching settings." });
  }
};

// @desc    Update global platform settings
// @route   PUT /api/admin/settings
export const updateSettings = async (req, res) => {
  try {
    // Find the single settings document and update it. 
    // upsert: true means if it somehow got deleted, Mongoose will recreate it.
    const updatedSettings = await PlatformSettings.findOneAndUpdate(
      {}, 
      { $set: req.body },
      { new: true, upsert: true }
    );

    res.status(200).json({ 
      message: "Platform settings updated successfully!", 
      settings: updatedSettings 
    });
  } catch (error) {
    console.error("Error updating settings:", error);
    res.status(500).json({ message: "Server error while updating settings." });
  }
};