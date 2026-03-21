import React from 'react';
import StatsCard from '../components/ui/StatsCard.jsx';
import RevenueChart from '../components/ui/RevenueChart.jsx';
import { DollarSign, Users, Store, ShieldAlert } from 'lucide-react';

const Dashboard = () => {
  return (
    <div className="space-y-6 w-full">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-white tracking-wide">Dashboard</h1>
      </div>

      {/* Top Metric Cards - 4 columns */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
        <StatsCard title="Total Revenue" value="$284,500" icon={DollarSign} trend="up" trendValue="12.5%" />
        <StatsCard title="Total Users" value="12,847" icon={Users} trend="up" trendValue="8.2%" />
        <StatsCard title="Active Sellers" value="342" icon={Store} trend="up" trendValue="5.1%" />
        <StatsCard title="Pending Requests" value="18" icon={ShieldAlert} trend="down" trendValue="3" />
      </div>

      {/* Main Chart Area - Takes up full width, no sidebar */}
      <div className="w-full mt-6">
        <RevenueChart />
      </div>

    </div>
  );
};

export default Dashboard;