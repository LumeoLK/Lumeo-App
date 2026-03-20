import React, { useState } from 'react';
import { Save, User, Mail, Lock, Shield, Bell, Camera } from 'lucide-react';

const Settings = () => {
  // Dummy state for Admin profile
  const [profile, setProfile] = useState({
    fullName: 'Admin User',
    email: 'superadmin@lumeo.lk',
    role: 'Super Admin',
  });

  // Dummy state for toggles
  const [notifications, setNotifications] = useState({
    newSellers: true,
    systemAlerts: true,
    weeklyReports: false,
  });

  return (
    <div className="w-full space-y-8">
      
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 border-b border-zinc-800 pb-6">
        <div>
          <h1 className="text-2xl font-bold text-white tracking-wide">Account Settings</h1>
          <p className="text-zinc-500 text-sm mt-1">Manage your personal admin profile and security preferences.</p>
        </div>
        
        <button className="flex items-center gap-2 bg-brand text-black px-6 py-2.5 rounded-xl font-bold text-sm hover:bg-brand/90 transition-colors">
          <Save className="w-4 h-4" />
          Save Changes
        </button>
      </div>

      <div className="space-y-8">
        
        {/* --- SECTION 1: Personal Information --- */}
        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-1/3">
            <h2 className="text-lg font-bold text-white">Personal Information</h2>
            <p className="text-sm text-zinc-500 mt-1">
              Update your photo and personal details here.
            </p>
          </div>
          
          <div className="md:w-2/3 bg-[#111111] border border-zinc-800 rounded-2xl p-6 space-y-6">
            
            {/* Avatar Upload UI */}
            <div className="flex items-center gap-6 pb-6 border-b border-zinc-800/50">
              <div className="relative group cursor-pointer">
                <img 
                  src="https://ui-avatars.com/api/?name=Admin+User&background=FBB040&color=000" 
                  alt="Admin Avatar" 
                  className="w-20 h-20 rounded-full object-cover border-2 border-zinc-800"
                />
                <div className="absolute inset-0 bg-black/50 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                  <Camera className="w-6 h-6 text-white" />
                </div>
              </div>
              <div>
                <button className="px-4 py-2 bg-[#09090b] text-white text-sm font-medium rounded-lg border border-zinc-800 hover:border-zinc-600 transition-colors">
                  Change Avatar
                </button>
                <p className="text-xs text-zinc-500 mt-2">JPG, GIF or PNG. 1MB max.</p>
              </div>
            </div>

            {/* Profile Fields */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Full Name</label>
                <div className="relative">
                  <User className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input 
                    type="text" 
                    value={profile.fullName}
                    onChange={(e) => setProfile({...profile, fullName: e.target.value})}
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Email Address</label>
                <div className="relative">
                  <Mail className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input 
                    type="email" 
                    value={profile.email}
                    onChange={(e) => setProfile({...profile, email: e.target.value})}
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>

              {/* Disabled Role Field */}
              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-medium text-zinc-400">Account Role</label>
                <input 
                  type="text" 
                  value={profile.role}
                  disabled
                  className="w-full bg-[#09090b]/50 text-zinc-500 px-4 py-2.5 rounded-xl border border-zinc-800/50 cursor-not-allowed text-sm"
                />
                <p className="text-xs text-brand mt-1">Contact system administrators to change role permissions.</p>
              </div>
            </div>

          </div>
        </div>

        {/* --- SECTION 2: Security & Passwords --- */}
        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-1/3">
            <h2 className="text-lg font-bold text-white">Security</h2>
            <p className="text-sm text-zinc-500 mt-1">
              Ensure your account is using a long, random password to stay secure.
            </p>
          </div>
          
          <div className="md:w-2/3 bg-[#111111] border border-zinc-800 rounded-2xl p-6 space-y-6">
            
            <div className="space-y-6">
              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-400">Current Password</label>
                <div className="relative">
                  <Lock className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input 
                    type="password" 
                    placeholder="••••••••"
                    className="w-full bg-[#09090b] text-white pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-zinc-400">New Password</label>
                  <input 
                    type="password" 
                    placeholder="Enter new password"
                    className="w-full bg-[#09090b] text-white px-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-zinc-400">Confirm Password</label>
                  <input 
                    type="password" 
                    placeholder="Confirm new password"
                    className="w-full bg-[#09090b] text-white px-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
                  />
                </div>
              </div>

              {/* 2FA Toggle */}
              <div className="flex items-center justify-between bg-[#09090b] p-4 rounded-xl border border-zinc-800 mt-4">
                <div className="flex items-center gap-3">
                  <div className="p-2 bg-brand/10 rounded-lg">
                    <Shield className="w-5 h-5 text-brand" />
                  </div>
                  <div>
                    <span className="text-sm font-medium text-white block">Two-Factor Authentication</span>
                    <span className="text-xs text-zinc-500">Add an extra layer of security to your account.</span>
                  </div>
                </div>
                <button className="w-10 h-5 bg-brand rounded-full relative transition-colors focus:outline-none">
                  <span className="absolute right-1 top-1 bg-black w-3 h-3 rounded-full"></span>
                </button>
              </div>
            </div>

          </div>
        </div>

        {/* --- SECTION 3: Notifications --- */}
        <div className="flex flex-col md:flex-row gap-8">
          <div className="md:w-1/3">
            <h2 className="text-lg font-bold text-white">Notifications</h2>
            <p className="text-sm text-zinc-500 mt-1">
              Choose what alerts you want to receive at your admin email address.
            </p>
          </div>
          
          <div className="md:w-2/3 bg-[#111111] border border-zinc-800 rounded-2xl p-6 space-y-4">
            
            {/* Toggle 1 */}
            <div className="flex items-center justify-between py-3 border-b border-zinc-800/50">
              <div className="flex items-center gap-3">
                <Bell className="w-5 h-5 text-zinc-400" />
                <div>
                  <span className="text-sm font-medium text-zinc-200 block">New Seller Applications</span>
                  <span className="text-xs text-zinc-500">Get an email when a new store applies to Lumeo.</span>
                </div>
              </div>
              <button 
                onClick={() => setNotifications({...notifications, newSellers: !notifications.newSellers})}
                className={`w-10 h-5 rounded-full relative transition-colors focus:outline-none ${notifications.newSellers ? 'bg-brand' : 'bg-zinc-700'}`}
              >
                <span className={`absolute top-1 w-3 h-3 rounded-full transition-all ${notifications.newSellers ? 'right-1 bg-black' : 'left-1 bg-zinc-300'}`}></span>
              </button>
            </div>

            {/* Toggle 2 */}
            <div className="flex items-center justify-between py-3 border-b border-zinc-800/50">
              <div className="flex items-center gap-3">
                <Shield className="w-5 h-5 text-zinc-400" />
                <div>
                  <span className="text-sm font-medium text-zinc-200 block">System Alerts</span>
                  <span className="text-xs text-zinc-500">Important security and platform maintenance notices.</span>
                </div>
              </div>
              <button 
                onClick={() => setNotifications({...notifications, systemAlerts: !notifications.systemAlerts})}
                className={`w-10 h-5 rounded-full relative transition-colors focus:outline-none ${notifications.systemAlerts ? 'bg-brand' : 'bg-zinc-700'}`}
              >
                <span className={`absolute top-1 w-3 h-3 rounded-full transition-all ${notifications.systemAlerts ? 'right-1 bg-black' : 'left-1 bg-zinc-300'}`}></span>
              </button>
            </div>

            {/* Toggle 3 */}
            <div className="flex items-center justify-between py-3">
              <div className="flex items-center gap-3">
                <Mail className="w-5 h-5 text-zinc-400" />
                <div>
                  <span className="text-sm font-medium text-zinc-200 block">Weekly Reports</span>
                  <span className="text-xs text-zinc-500">A summary of orders and platform revenue.</span>
                </div>
              </div>
              <button 
                onClick={() => setNotifications({...notifications, weeklyReports: !notifications.weeklyReports})}
                className={`w-10 h-5 rounded-full relative transition-colors focus:outline-none ${notifications.weeklyReports ? 'bg-brand' : 'bg-zinc-700'}`}
              >
                <span className={`absolute top-1 w-3 h-3 rounded-full transition-all ${notifications.weeklyReports ? 'right-1 bg-black' : 'left-1 bg-zinc-300'}`}></span>
              </button>
            </div>

          </div>
        </div>

      </div>
    </div>
  );
};

export default Settings;