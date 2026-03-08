import React from 'react';
import { Search, Bell } from 'lucide-react';

const Topbar = () => {
  return (
    <header className="h-20 bg-[#09090b] border-b border-zinc-800 flex items-center justify-between px-8 sticky top-0 z-10">
      {/* Breadcrumbs */}
      <div>
        <h1 className="text-white text-xl font-bold">Dashboard</h1>
        <p className="text-zinc-500 text-sm">Admin / Dashboard</p>
      </div>

      {/* Right Side Actions */}
      <div className="flex items-center gap-6">
        {/* Search */}
        <div className="relative">
          <Search className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
          <input 
            type="text" 
            placeholder="Global search..." 
            className="bg-zinc-900 text-zinc-200 pl-10 pr-4 py-2.5 rounded-full border border-zinc-800 focus:outline-none focus:border-orange-500 w-64 text-sm"
          />
        </div>

        {/* Notifications */}
        <button className="relative p-2 text-zinc-400 hover:text-white transition-colors">
          <Bell className="w-6 h-6" />
          <span className="absolute top-2 right-2 w-2 h-2 bg-orange-500 rounded-full border-2 border-[#09090b]"></span>
        </button>
        
        {/* Profile Avatar */}
        <div className="w-10 h-10 rounded-full bg-amber-900/50 text-orange-500 flex items-center justify-center font-bold border border-orange-500/20">
          AD
        </div>
      </div>
    </header>
  );
};

export default Topbar;