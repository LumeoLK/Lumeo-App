import React, { useState, useEffect } from 'react';
import StatsCard from '../components/ui/StatsCard.jsx';
import RevenueChart from '../components/ui/RevenueChart.jsx';
import { DollarSign, Users, Store, ShieldAlert } from 'lucide-react';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalRevenue: 0,
    totalUsers: 0,
    activeSellers: 0,
    pendingRequests: 0
  });
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await fetch('http://localhost:3000/api/admin/dashboard-stats');
        if (response.ok) {
          const data = await response.json();
          setStats(data);
        }
      } catch (error) {
        console.error("Error fetching dashboard stats:", error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchStats();
  }, []);

  return (
    <div className="space-y-6 w-full">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-white tracking-wide">Dashboard</h1>
      </div>

      {/* Top Metric Cards - 4 columns */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
        <StatsCard 
          title="Total Revenue" 
          value={isLoading ? "..." : `Rs. ${stats.totalRevenue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`} 
          icon={DollarSign} 
          trend="up" 
          trendValue="Live" 
        />
        <StatsCard 
          title="Total Users" 
          value={isLoading ? "..." : stats.totalUsers.toLocaleString()} 
          icon={Users} 
          trend="up" 
          trendValue="Live" 
        />
        <StatsCard 
          title="Active Sellers" 
          value={isLoading ? "..." : stats.activeSellers.toLocaleString()} 
          icon={Store} 
          trend="up" 
          trendValue="Live" 
        />
        <StatsCard 
          title="Pending Requests" 
          value={isLoading ? "..." : stats.pendingRequests.toString()} 
          icon={ShieldAlert} 
          trend={stats.pendingRequests > 0 ? "down" : "up"} 
          trendValue="Needs Review" 
        />
      </div>

      {/* Main Chart Area - Takes up full width, no sidebar */}
      <div className="w-full mt-6">
        <RevenueChart />
      </div>

    </div>
  );
};

export default Dashboard;