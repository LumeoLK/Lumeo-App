import mongoose from "mongoose";

const platformSettingsSchema = new mongoose.Schema({
  // Financials
  commissionRate: { type: Number, default: 10 },
  taxRate: { type: Number, default: 15 },
  minPayout: { type: Number, default: 5000 },
  
  // AR Engine
  arQuality: { type: String, enum: ['Standard', 'High', 'Ultra'], default: 'High' },
  maxUploadSize: { type: Number, default: 50 },
  autoApproveModels: { type: Boolean, default: false },
  
  // Seller Management
  requireBizReg: { type: Boolean, default: true },
  autoApproveSellers: { type: Boolean, default: false },
  
  // Admin Security
  adminEmail: { type: String, default: 'admin@lumeo.com' }
}, { timestamps: true });

export default mongoose.model("PlatformSettings", platformSettingsSchema);