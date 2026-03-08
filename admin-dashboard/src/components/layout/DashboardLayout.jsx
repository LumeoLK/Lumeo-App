import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Topbar from './Topbar';

const DashboardLayout = () => {
  return (
    <div className="flex min-h-screen bg-[#09090b]">
      <Sidebar />
      <div className="flex-1 ml-64">
        <Topbar />
        <main className="p-8">
          {/* This renders the current page content */}
          <Outlet /> 
        </main>
      </div>
    </div>
  );
};

export default DashboardLayout;