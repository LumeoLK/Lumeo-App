import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Users, 
  ShieldCheck, 
  Package, 
  ShoppingCart, 
  Palette, 
  Settings, 
  LogOut 
} from 'lucide-react';

const Sidebar = () => {
  const navItems = [
    { path: '/', label: 'Dashboard', icon: LayoutDashboard },
    { path: '/users', label: 'Users', icon: Users },
    { path: '/sellers', label: 'Seller Verification', icon: ShieldCheck, notification: true },
    { path: '/products', label: 'Products', icon: Package },
    { path: '/orders', label: 'Orders', icon: ShoppingCart },
    { path: '/requests', label: 'Custom Requests', icon: Palette },
    { path: '/settings', label: 'Settings', icon: Settings },
  ];

  return (
    <div className="w-64 h-screen bg-[#111111] border-r border-zinc-800 flex flex-col fixed left-0 top-0">
      {/* Logo */}
      <div className="p-6 flex items-center gap-3">
        <div className="w-8 h-8 bg-orange-500 rounded-lg flex items-center justify-center">
          <span className="text-black font-bold text-lg">L</span>
        </div>
        <span className="text-white text-xl font-bold tracking-wide">Lumeo.</span>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-4 py-4 space-y-2">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 group ${
                isActive 
                  ? 'bg-zinc-800 text-orange-500' 
                  : 'text-zinc-400 hover:bg-zinc-900 hover:text-white'
              }`
            }
          >
            <item.icon className="w-5 h-5" />
            <span className="font-medium">{item.label}</span>
            {item.notification && (
              <span className="ml-auto w-2 h-2 rounded-full bg-orange-500" />
            )}
          </NavLink>
        ))}
      </nav>

      {/* User Profile */}
      <div className="p-4 border-t border-zinc-800">
        <div className="flex items-center gap-3 p-3 rounded-xl hover:bg-zinc-900 cursor-pointer transition-colors">
          <img 
            src="https://ui-avatars.com/api/?name=Admin+User&background=random" 
            alt="Admin" 
            className="w-10 h-10 rounded-full"
          />
          <div className="flex-1">
            <h4 className="text-white text-sm font-semibold">Admin User</h4>
            <p className="text-zinc-500 text-xs">Super Admin</p>
          </div>
          <LogOut className="w-5 h-5 text-zinc-500 hover:text-red-400" />
        </div>
      </div>
    </div>
  );
};

export default Sidebar;