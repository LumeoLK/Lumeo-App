import React from 'react';

const StatsCard = ({ title, value, icon: Icon, trend, trendValue }) => {
  const isPositive = trend === 'up';

  return (
    <div className="bg-[#111111] border border-zinc-800 rounded-2xl p-6 flex flex-col justify-between">
      {/* Top Half: Title and Icon */}
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-zinc-400 text-sm font-medium mb-1">{title}</h3>
          <h2 className="text-white text-3xl font-bold">{value}</h2>
        </div>
        
        {/* The Icon Container */}
        <div className="w-10 h-10 rounded-xl bg-amber-900/20 flex items-center justify-center border border-amber-500/20">
          <Icon className="w-5 h-5 text-orange-500" />
        </div>
      </div>

      {/* Bottom Half: Trend Indicator */}
      <div className="flex items-center gap-2 text-sm">
        <span className={`font-medium flex items-center ${isPositive ? 'text-emerald-500' : 'text-red-500'}`}>
          <svg 
            className={`w-4 h-4 mr-1 ${!isPositive && 'rotate-180'}`} 
            fill="none" 
            viewBox="0 0 24 24" 
            stroke="currentColor"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 10l7-7m0 0l7 7m-7-7v18" />
          </svg>
          {trendValue}
        </span>
        <span className="text-zinc-500">vs last month</span>
      </div>
    </div>
  );
};

export default StatsCard;