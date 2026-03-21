import React, { useState, useEffect } from 'react';
import { 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  Tooltip, 
  ResponsiveContainer 
} from 'recharts';

const RevenueChart = () => {
  const [activeTab, setActiveTab] = useState('Week');
  const [chartData, setChartData] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchChartData();
  }, []);

  const fetchChartData = async () => {
    try {
      const response = await fetch('http://localhost:3000/api/admin/revenue-chart');
      if (response.ok) {
        const apiData = await response.json();
        
        // Smart Data Processing: Build the last 7 days perfectly
        const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        const formattedData = [];
        
        // Loop backwards from 6 days ago to today
        for (let i = 6; i >= 0; i--) {
          const d = new Date();
          d.setDate(d.getDate() - i);
          const dateString = d.toISOString().split('T')[0]; // Format: YYYY-MM-DD
          const dayName = days[d.getDay()]; // Gets 'Mon', 'Tue', etc.

          // Check if MongoDB returned revenue for this specific date
          const foundMatch = apiData.find(item => item._id === dateString);
          
          formattedData.push({
            name: dayName,
            revenue: foundMatch ? foundMatch.revenue : 0 // If no sales, default to 0
          });
        }
        
        setChartData(formattedData);
      }
    } catch (error) {
      console.error("Failed to fetch chart data:", error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="bg-[#111111] border border-zinc-800 rounded-2xl p-6 w-full">
      
      {/* Chart Header & Time Toggles */}
      <div className="flex justify-between items-center mb-8">
        <h2 className="text-xl font-bold text-white">Revenue Overview</h2>
        
        <div className="flex bg-[#09090b] rounded-lg p-1 border border-zinc-800">
          {['Day', 'Week', 'Month'].map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`px-4 py-1.5 text-sm font-medium rounded-md transition-all ${
                activeTab === tab 
                  ? 'bg-[#FBB040] text-black' 
                  : 'text-zinc-400 hover:text-white'
              }`}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>

      {/* Chart Graph Area */}
      <div className="h-[350px] w-full relative">
        {isLoading ? (
          <div className="absolute inset-0 flex items-center justify-center text-zinc-500">
            Loading chart data...
          </div>
        ) : (
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={chartData} margin={{ top: 10, right: 0, left: -20, bottom: 0 }}>
              <defs>
                <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#f9d225" stopOpacity={0.3}/>
                  <stop offset="95%" stopColor="#FBB040" stopOpacity={0}/>
                </linearGradient>
              </defs>
              <XAxis dataKey="name" stroke="#52525b" fontSize={12} tickLine={false} axisLine={false} />
              
              {/* Formatted to Rs. */}
              <YAxis 
                stroke="#52525b" 
                fontSize={12} 
                tickLine={false} 
                axisLine={false} 
                tickFormatter={(value) => `Rs.${value}`} 
              />
              
              <Tooltip 
                contentStyle={{ backgroundColor: '#18181b', borderColor: '#27272a', borderRadius: '8px', color: '#fff' }}
                itemStyle={{ color: '#FBB040' }}
                formatter={(value) => [`Rs. ${value}`, 'Revenue']}
              />
              
              <Area 
                type="monotone" 
                dataKey="revenue" 
                stroke="#FBB040" 
                strokeWidth={3} 
                fillOpacity={1} 
                fill="url(#colorRevenue)" 
              />
            </AreaChart>
          </ResponsiveContainer>
        )}
      </div>
    </div>
  );
};

export default RevenueChart;