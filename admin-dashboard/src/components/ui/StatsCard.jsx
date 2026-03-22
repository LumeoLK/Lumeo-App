import React from 'react';

const StatsCard = ({ title, value, icon: Icon }) => {
  return (
    <div className="bg-[#111111] border border-zinc-800 rounded-2xl p-6 flex flex-col justify-center">
      <div className="flex justify-between items-start">
        <div>
          <h3 className="text-zinc-400 text-sm font-medium mb-1">{title}</h3>
          <h2 className="text-white text-3xl font-bold">{value}</h2>
        </div>
        
        {/* The Icon Container */}
        <div className="w-10 h-10 rounded-xl bg-amber-900/20 flex items-center justify-center border border-amber-500/20">
          <Icon className="w-5 h-5 text-brand" />
        </div>
      </div>
    </div>
  );
};

export default StatsCard;