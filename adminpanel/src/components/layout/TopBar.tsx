import React from 'react';
import { useLocation } from 'react-router-dom';
import { Bell, Menu, Search } from 'lucide-react';
import { Input } from '../ui/Input';
interface TopBarProps {
  onMenuClick: () => void;
}
export function TopBar({ onMenuClick }: TopBarProps) {
  const location = useLocation();
  const getPageTitle = () => {
    const path = location.pathname;
    if (path === '/') return 'Dashboard';
    if (path.startsWith('/users')) return 'User Management';
    if (path.startsWith('/sellers')) return 'Seller Verification';
    if (path.startsWith('/products')) return 'Product Management';
    if (path.startsWith('/orders')) return 'Order Management';
    if (path.startsWith('/custom-requests')) return 'Custom Requests';
    if (path.startsWith('/settings')) return 'Settings';
    return 'Dashboard';
  };
  return (
    <header className="sticky top-0 z-20 bg-dark-bg/80 backdrop-blur-md border-b border-dark-border h-16 px-4 lg:px-8 flex items-center justify-between">
      <div className="flex items-center gap-4">
        <button
          onClick={onMenuClick}
          className="lg:hidden p-2 text-gray-400 hover:text-white hover:bg-dark-surface rounded-lg">

          <Menu className="h-5 w-5" />
        </button>

        <div>
          <h1 className="text-lg font-semibold text-white">{getPageTitle()}</h1>
          <div className="hidden md:flex items-center text-xs text-gray-500 mt-0.5">
            <span>Admin</span>
            <span className="mx-2">/</span>
            <span className="text-gray-400">{getPageTitle()}</span>
          </div>
        </div>
      </div>

      <div className="flex items-center gap-4">
        <div className="hidden md:block w-64">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
            <input
              type="text"
              placeholder="Global search..."
              className="w-full bg-dark-surface border border-dark-border rounded-full py-1.5 pl-9 pr-4 text-sm text-gray-300 focus:outline-none focus:border-brand-accent/50 transition-colors" />

          </div>
        </div>

        <button className="relative p-2 text-gray-400 hover:text-white hover:bg-dark-surface rounded-full transition-colors">
          <Bell className="h-5 w-5" />
          <span className="absolute top-2 right-2 w-2 h-2 bg-status-danger rounded-full border-2 border-dark-bg" />
        </button>

        <div className="h-8 w-8 rounded-full bg-brand-accent/20 border border-brand-accent/30 flex items-center justify-center text-brand-accent font-medium text-sm">
          AD
        </div>
      </div>
    </header>);

}