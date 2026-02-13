import React from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  ShieldCheck,
  Package,
  ShoppingCart,
  Palette,
  Settings,
  LogOut,
  Menu,
  X } from
'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { cn } from '../../lib/utils';
interface SidebarProps {
  isOpen: boolean;
  setIsOpen: (isOpen: boolean) => void;
}
export function Sidebar({ isOpen, setIsOpen }: SidebarProps) {
  const location = useLocation();
  const navItems = [
  {
    name: 'Dashboard',
    path: '/',
    icon: LayoutDashboard
  },
  {
    name: 'Users',
    path: '/users',
    icon: Users
  },
  {
    name: 'Seller Verification',
    path: '/sellers/verification',
    icon: ShieldCheck,
    badge: true
  },
  {
    name: 'Products',
    path: '/products',
    icon: Package
  },
  {
    name: 'Orders',
    path: '/orders',
    icon: ShoppingCart
  },
  {
    name: 'Custom Requests',
    path: '/custom-requests',
    icon: Palette
  },
  {
    name: 'Settings',
    path: '/settings',
    icon: Settings
  }];

  const SidebarContent = () =>
  <div className="flex flex-col h-full bg-brand-primary border-r border-dark-border">
      {/* Logo */}
      <div className="h-16 flex items-center px-6 border-b border-dark-border">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 bg-brand-accent rounded-md flex items-center justify-center transform rotate-3">
            <div className="w-4 h-4 bg-brand-primary rounded-sm" />
          </div>
          <span className="text-xl font-bold text-white tracking-tight">
            Lumeo<span className="text-brand-accent">.</span>
          </span>
        </div>
      </div>

      {/* Nav Items */}
      <nav className="flex-1 py-6 px-3 space-y-1 overflow-y-auto">
        {navItems.map((item) => {
        const isActive =
        location.pathname === item.path ||
        item.path !== '/' && location.pathname.startsWith(item.path);
        return (
          <NavLink
            key={item.path}
            to={item.path}
            onClick={() => window.innerWidth < 1024 && setIsOpen(false)}
            className={({ isActive }) =>
            cn(
              'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all relative group',
              isActive ?
              'text-brand-accent bg-brand-accent/10' :
              'text-gray-400 hover:text-white hover:bg-white/5'
            )
            }>

              <item.icon
              className={cn(
                'h-5 w-5',
                isActive ?
                'text-brand-accent' :
                'text-gray-500 group-hover:text-gray-300'
              )} />

              {item.name}
              {isActive &&
            <motion.div
              layoutId="activeNav"
              className="absolute left-0 top-0 bottom-0 w-1 bg-brand-accent rounded-r-full" />

            }
              {item.badge &&
            <span className="ml-auto w-2 h-2 rounded-full bg-brand-accent animate-pulse" />
            }
            </NavLink>);

      })}
      </nav>

      {/* User Profile */}
      <div className="p-4 border-t border-dark-border">
        <div className="flex items-center gap-3 px-2 py-2 rounded-lg hover:bg-white/5 transition-colors cursor-pointer">
          <img
          src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
          alt="Admin"
          className="h-9 w-9 rounded-full border border-dark-border" />

          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-white truncate">
              Admin User
            </p>
            <p className="text-xs text-gray-500 truncate">Super Admin</p>
          </div>
          <LogOut className="h-4 w-4 text-gray-500 hover:text-white" />
        </div>
      </div>
    </div>;

  return (
    <>
      {/* Desktop Sidebar */}
      <div className="hidden lg:block w-[260px] fixed inset-y-0 left-0 z-30">
        <SidebarContent />
      </div>

      {/* Mobile Sidebar Overlay */}
      <AnimatePresence>
        {isOpen &&
        <>
            <motion.div
            initial={{
              opacity: 0
            }}
            animate={{
              opacity: 1
            }}
            exit={{
              opacity: 0
            }}
            onClick={() => setIsOpen(false)}
            className="fixed inset-0 bg-black/80 backdrop-blur-sm z-40 lg:hidden" />

            <motion.div
            initial={{
              x: -280
            }}
            animate={{
              x: 0
            }}
            exit={{
              x: -280
            }}
            transition={{
              type: 'spring',
              damping: 25,
              stiffness: 200
            }}
            className="fixed inset-y-0 left-0 w-[280px] z-50 lg:hidden">

              <SidebarContent />
            </motion.div>
          </>
        }
      </AnimatePresence>
    </>);

}