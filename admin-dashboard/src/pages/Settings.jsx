import React, { useState } from 'react';
import { Save, Store, Mail, Phone, MapPin, DollarSign, Percent, Box } from 'lucide-react';

const Settings = () => {
  // Dummy state for the settings form
  const [formData, setFormData] = useState({
    storeName: 'Lumeo Furniture',
    email: 'admin@lumeo.lk',
    phone: '+94 77 123 4567',
    address: '123 Galle Road, Colombo 03',
    currency: 'LKR',
    taxRate: '15',
    commission: '10',
    arQuality: 'High',
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  return (
    <div className="w-full space-y-8">
      
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 border-b border-zinc-800 pb-6">
        <div>
          <h1 className="text-2xl font-bold text-white tracking-wide">General Settings</h1>
        </div>
        
        <button className="flex items-center gap-2 bg-brand text-black px-6 py-2.5 rounded-xl font-bold text-sm hover:bg-brand/90 transition-colors">
          <Save className="w-4 h-4" />
          Save Changes
        </button>
      </div>

      <div className="space-y-8">
        
        {/* --- SECTION 1: Store Information --- */}
        <div className="flex flex-col md:flex-row gap-8">
          {/* Left Column: Description */}
          <div className="md:w-1/3">
            <h2 className="text-lg font-bold text-white">Store Information</h2>
            <p className="text-sm text-zinc-500 mt-1">
              Update your primary business details and contact information. This is visible to sellers.
            </p>
          </div>
          
          {/* Right Column: Form Card */}
          <div className="md:w-2/3 bg-[#111111] border border-zinc-800 rounded-2xl p-6 space-y-6">
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Store Name */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Store Name</label>
                <div className="relative">
                  <Store className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input 
                    type="text" 
                    name="storeName"
                    value={formData.storeName}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>

              {/* Contact Email */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Support Email</label>
                <div className="relative">
                  <Mail className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input 
                    type="email" 
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>

              {/* Phone Number */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Phone Number</label>
                <div className="relative">
                  <Phone className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input 
                    type="text" 
                    name="phone"
                    value={formData.phone}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>

              {/* Business Address */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Business Address</label>
                <div className="relative">
                  <MapPin className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input 
                    type="text" 
                    name="address"
                    value={formData.address}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>
            </div>

          </div>
        </div>

        {/* --- SECTION 2: Platform Financials --- */}
        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-1/3">
            <h2 className="text-lg font-bold text-white">Financial & Regional</h2>
            <p className="text-sm text-zinc-500 mt-1">
              Set your platform currency, seller commission rates, and baseline tax rules.
            </p>
          </div>
          
          <div className="md:w-2/3 bg-[#111111] border border-zinc-800 rounded-2xl p-6 space-y-6">
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Currency */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Default Currency</label>
                <div className="relative">
                  <DollarSign className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <select 
                    name="currency"
                    value={formData.currency}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm appearance-none cursor-pointer"
                  >
                    <option value="LKR">LKR (Rs)</option>
                    <option value="USD">USD ($)</option>
                    <option value="EUR">EUR (€)</option>
                  </select>
                </div>
              </div>

              {/* Commission Rate */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Seller Commission</label>
                <div className="relative">
                  <Percent className="w-4 h-4 text-zinc-500 absolute right-4 top-1/2 -translate-y-1/2" />
                  <input 
                    type="number" 
                    name="commission"
                    value={formData.commission}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white px-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
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
                    className="w-full bg-[#09090b] text-white px-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>
            </div>

          </div>
        </div>

        {/* --- SECTION 3: Lumeo AR Configurations --- */}
        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-1/3">
            <h2 className="text-lg font-bold text-white">AR Engine Configurations</h2>
            <p className="text-sm text-zinc-500 mt-1">
              Manage the 3D model requirements for sellers uploading furniture to the augmented reality viewer.
            </p>
          </div>
          
          <div className="md:w-2/3 bg-[#111111] border border-zinc-800 rounded-2xl p-6 space-y-6">
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* AR Export Quality */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Model Render Quality</label>
                <div className="relative">
                  <Box className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <select 
                    name="arQuality"
                    value={formData.arQuality}
                    onChange={handleChange}
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm appearance-none cursor-pointer"
                  >
                    <option value="Standard">Standard (Fast Loading)</option>
                    <option value="High">High (Balanced)</option>
                    <option value="Ultra">Ultra (Maximum Detail)</option>
                  </select>
                </div>
              </div>

              {/* Toggle: Auto-approve models */}
              <div className="flex items-center justify-between bg-[#09090b] p-4 rounded-xl border border-zinc-800 h-[42px] mt-7">
                <span className="text-sm text-zinc-300">Auto-Approve 3D Models</span>
                <button className="w-10 h-5 bg-brand rounded-full relative transition-colors focus:outline-none">
                  <span className="absolute right-1 top-1 bg-black w-3 h-3 rounded-full"></span>
                </button>
              </div>
            </div>

          </div>
        </div>

      </div>
    </div>
  );
};

export default Settings;