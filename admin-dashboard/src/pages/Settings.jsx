import React, { useState, useEffect } from 'react';
import { 
  Save, 
  DollarSign, 
  Percent, 
  Box, 
  ShieldCheck, 
  Lock, 
  Mail, 
  HardDrive,
  Settings2,
  UserCog,
  RefreshCw
} from 'lucide-react';

const Settings = () => {
  // 1. State for platform configurations
  const [formData, setFormData] = useState({
    commissionRate: 10,
    taxRate: 15,
    minPayout: 5000,
    arQuality: 'High',
    maxUploadSize: 50,
    autoApproveModels: false,
    requireBizReg: true,
    autoApproveSellers: false,
    adminEmail: 'admin@lumeo.com'
  });

  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  // 2. Fetch settings from backend on load
  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      const response = await fetch(`${import.meta.env.VITE_BACKEND_URL}/api/admin/settings`);
      if (response.ok) {
        const data = await response.json();
        // Merge fetched data with default state to prevent undefined errors
        setFormData(prev => ({ ...prev, ...data }));
      }
    } catch (error) {
      console.error("Failed to fetch settings:", error);
    } finally {
      setIsLoading(false);
    }
  };

  // 3. Save settings to backend
  const handleSave = async () => {
    setIsSaving(true);
    try {
      const response = await fetch(`${import.meta.env.VITE_BACKEND_URL}/api/admin/settings`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });
      
      if (response.ok) {
        alert("Platform settings saved successfully!");
      } else {
        alert("Failed to save settings. Please try again.");
      }
    } catch (error) {
      console.error("Error saving settings:", error);
      alert("An error occurred while saving.");
    } finally {
      setIsSaving(false);
    }
  };

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleToggle = (field) => {
    setFormData({ ...formData, [field]: !formData[field] });
  };

  // Reusable Toggle Switch Component
  const ToggleSwitch = ({ label, field, description }) => (
    <div className="flex items-center justify-between bg-[#09090b] p-4 rounded-xl border border-zinc-800">
      <div>
        <span className="text-sm font-medium text-zinc-200 block">{label}</span>
        {description && <span className="text-xs text-zinc-500">{description}</span>}
      </div>
      <button 
        onClick={() => handleToggle(field)}
        className={`w-11 h-6 rounded-full relative transition-colors focus:outline-none ${formData[field] ? 'bg-brand' : 'bg-zinc-700'}`}
      >
        <span className={`absolute top-1 w-4 h-4 rounded-full bg-[#09090b] transition-all ${formData[field] ? 'right-1' : 'left-1'}`}></span>
      </button>
    </div>
  );

  if (isLoading) {
    return <div className="text-white p-8 flex items-center gap-2"><RefreshCw className="w-5 h-5 animate-spin"/> Loading platform configurations...</div>;
  }

  return (
    <div className="w-full space-y-8 pb-10">
      
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 border-b border-zinc-800 pb-6">
        <div>
          <h1 className="text-2xl font-bold text-white tracking-wide">Platform Settings</h1>
        </div>
        
        <button 
          onClick={handleSave}
          disabled={isSaving}
          className="flex items-center gap-2 bg-brand text-black px-6 py-2.5 rounded-xl font-bold text-sm hover:bg-brand/90 transition-colors disabled:opacity-70 disabled:cursor-not-allowed"
        >
          {isSaving ? <RefreshCw className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
          {isSaving ? 'Saving...' : 'Save Changes'}
        </button>
      </div>

      <div className="space-y-8">
        
        {/* --- SECTION 1: Platform Financials --- */}
        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-1/3">
            <div className="flex items-center gap-2 mb-2">
              <DollarSign className="w-5 h-5 text-brand" />
              <h2 className="text-lg font-bold text-white">Marketplace Financials</h2>
            </div>
            <p className="text-sm text-zinc-500">
              Set the platform commission rates, baseline tax rules, and seller payout thresholds.
            </p>
          </div>
          
          <div className="md:w-2/3 bg-[#111111] border border-zinc-800 rounded-2xl p-6 space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Commission Rate */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Platform Commission</label>
                <div className="relative">
                  <Percent className="w-4 h-4 text-zinc-500 absolute right-4 top-1/2 -translate-y-1/2" />
                  <input 
                    type="number" 
                    name="commissionRate"
                    value={formData.commissionRate}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-4 pr-10 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>

              {/* Tax Rate */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Standard Tax Rate</label>
                <div className="relative">
                  <Percent className="w-4 h-4 text-zinc-500 absolute right-4 top-1/2 -translate-y-1/2" />
                  <input 
                    type="number" 
                    name="taxRate"
                    value={formData.taxRate}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-4 pr-10 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>

              {/* Minimum Payout */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Min. Seller Payout</label>
                <div className="relative">
                  <span className="text-zinc-500 absolute left-4 top-1/2 -translate-y-1/2 text-sm font-medium">Rs.</span>
                  <input 
                    type="number" 
                    name="minPayout"
                    value={formData.minPayout}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* --- SECTION 2: AR Engine Configurations --- */}
        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-1/3">
            <div className="flex items-center gap-2 mb-2">
              <Settings2 className="w-5 h-5 text-brand" />
              <h2 className="text-lg font-bold text-white">3D & AR Pipeline</h2>
            </div>
            <p className="text-sm text-zinc-500">
              Manage Meshy AI generation quality, file upload limits, and approval workflows.
            </p>
          </div>
          
          <div className="md:w-2/3 bg-[#111111] border border-zinc-800 rounded-2xl p-6 space-y-6">
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* AR Export Quality */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Default AI Render Quality</label>
                <div className="relative">
                  <Box className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <select 
                    name="arQuality"
                    value={formData.arQuality}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm appearance-none cursor-pointer"
                  >
                    <option value="Standard">Standard (Fast / Low API Cost)</option>
                    <option value="High">High (Balanced)</option>
                    <option value="Ultra">Ultra (Slow / High API Cost)</option>
                  </select>
                </div>
              </div>

              {/* Max Upload Size */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Max GLB Upload Size</label>
                <div className="relative">
                  <HardDrive className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <span className="text-zinc-500 absolute right-4 top-1/2 -translate-y-1/2 text-sm">MB</span>
                  <input 
                    type="number" 
                    name="maxUploadSize"
                    value={formData.maxUploadSize}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-10 pr-10 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>
            </div>

            <ToggleSwitch 
              label="Auto-Approve AI Generated Models" 
              field="autoApproveModels"
              description="Instantly publish successful Meshy 3D generations without manual admin review."
            />

          </div>
        </div>

        {/* --- SECTION 3: Seller Management --- */}
        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-1/3">
            <div className="flex items-center gap-2 mb-2">
              <UserCog className="w-5 h-5 text-brand" />
              <h2 className="text-lg font-bold text-white">Seller Management</h2>
            </div>
            <p className="text-sm text-zinc-500">
              Configure the strictness of the seller verification and onboarding process.
            </p>
          </div>
          
          <div className="md:w-2/3 bg-[#111111] border border-zinc-800 rounded-2xl p-6 space-y-4">
            <ToggleSwitch 
              label="Require Business Registration Number" 
              field="requireBizReg"
              description="Forces new applicants to provide a valid BRN. Disabling this allows casual individual sellers."
            />
            <ToggleSwitch 
              label="Auto-Approve New Sellers" 
              field="autoApproveSellers"
              description="Bypasses the manual NIC verification queue (Not recommended for production)."
            />
          </div>
        </div>

        {/* --- SECTION 4: Admin Security --- */}
        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-1/3">
            <div className="flex items-center gap-2 mb-2">
              <ShieldCheck className="w-5 h-5 text-brand" />
              <h2 className="text-lg font-bold text-white">Admin Security</h2>
            </div>
            <p className="text-sm text-zinc-500">
              Manage root access and critical system notification settings.
            </p>
          </div>
          
          <div className="md:w-2/3 bg-[#111111] border border-zinc-800 rounded-2xl p-6 space-y-6">
            
            <div className="space-y-2">
              <label className="text-sm font-medium text-zinc-400">System Notification Email</label>
              <div className="relative">
                <Mail className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                <input 
                  type="email" 
                  name="adminEmail"
                  value={formData.adminEmail}
                  onChange={handleChange}
                  className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                />
              </div>
            </div>

            <div className="pt-4 border-t border-zinc-800/50">
              <button className="flex items-center gap-2 px-5 py-2.5 rounded-xl border border-zinc-700 text-zinc-300 hover:bg-zinc-800 hover:text-white font-medium text-sm transition-colors">
                <Lock className="w-4 h-4" />
                Change Root Password
              </button>
            </div>

          </div>
        </div>

      </div>
    </div>
  );
};

export default Settings;