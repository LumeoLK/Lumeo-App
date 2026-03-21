import React, { useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';

// Dummy data
const initialOrders = [
  { id: '#ORD-1000', customer: 'Customer 1', seller: 'Shop 1', amount: 694.18, date: '2023-10-25', status: 'Pending' },
  { id: '#ORD-1001', customer: 'Customer 2', seller: 'Shop 2', amount: 764.45, date: '2023-10-25', status: 'Shipped' },
  { id: '#ORD-1002', customer: 'Customer 3', seller: 'Shop 3', amount: 267.55, date: '2023-10-25', status: 'Delivered' },
  { id: '#ORD-1003', customer: 'Customer 4', seller: 'Shop 4', amount: 494.71, date: '2023-10-25', status: 'Cancelled' },
  { id: '#ORD-1004', customer: 'Customer 5', seller: 'Shop 5', amount: 435.40, date: '2023-10-25', status: 'Pending' },
  { id: '#ORD-1005', customer: 'Customer 6', seller: 'Shop 1', amount: 747.49, date: '2023-10-25', status: 'Shipped' },
  { id: '#ORD-1006', customer: 'Customer 7', seller: 'Shop 2', amount: 67.15, date: '2023-10-25', status: 'Delivered' },
  { id: '#ORD-1007', customer: 'Customer 8', seller: 'Shop 3', amount: 506.74, date: '2023-10-25', status: 'Cancelled' },
  { id: '#ORD-1008', customer: 'Customer 9', seller: 'Shop 4', amount: 281.77, date: '2023-10-25', status: 'Pending' },
  { id: '#ORD-1009', customer: 'Customer 10', seller: 'Shop 5', amount: 112.73, date: '2023-10-25', status: 'Shipped' },
];

const tabs = ['All', 'Pending', 'Shipped', 'Delivered', 'Cancelled'];

const OrderManagement = () => {
  const [activeTab, setActiveTab] = useState('All');
  const [itemsPerPage, setItemsPerPage] = useState(10);

  // 1. Filter by the active tab
  const filteredOrders = activeTab === 'All' 
    ? initialOrders 
    : initialOrders.filter(order => order.status === activeTab);

  // 2. Slice the array so we only show the allowed "items per page"
  const displayedOrders = filteredOrders.slice(0, itemsPerPage);

  const getStatusBadge = (status) => {
    switch (status) {
      case 'Pending': return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20';
      case 'Shipped': return 'bg-blue-500/10 text-blue-500 border-blue-500/20';
      case 'Delivered': return 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20';
      case 'Cancelled': return 'bg-red-500/10 text-red-500 border-red-500/20';
      default: return 'bg-zinc-500/10 text-zinc-500 border-zinc-500/20';
    }
  };

  const getStatusDot = (status) => {
    switch (status) {
      case 'Pending': return 'bg-yellow-500';
      case 'Shipped': return 'bg-blue-500';
      case 'Delivered': return 'bg-emerald-500';
      case 'Cancelled': return 'bg-red-500';
      default: return 'bg-zinc-500';
    }
  };

  return (
    <div className="w-full space-y-6">
      
      <div>
        <h1 className="text-2xl font-bold text-white tracking-wide">Order Management</h1>
      </div>

      <div className="flex gap-8 border-b border-zinc-800">
        {tabs.map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`pb-4 text-sm font-medium transition-colors relative ${
              activeTab === tab 
                ? 'text-brand' 
                : 'text-zinc-500 hover:text-zinc-300'
            }`}
          >
            {tab}
            {activeTab === tab && (
              <span className="absolute bottom-0 left-0 w-full h-0.5 bg-brand rounded-t-full"></span>
            )}
          </button>
        ))}
      </div>

      <div className="bg-[#111111] rounded-2xl border border-zinc-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            
            <thead>
              <tr className="border-b border-zinc-800 text-zinc-400 text-xs font-bold uppercase tracking-wider">
                <th className="px-6 py-5 w-[16.6%] text-brand">Order ID</th>
                <th className="px-6 py-5 w-[16.6%]">Customer</th>
                <th className="px-6 py-5 w-[16.6%]">Seller</th>
                <th className="px-6 py-5 w-[16.6%]">Amount</th>
                <th className="px-6 py-5 w-[16.6%]">Date</th>
                <th className="px-6 py-5 w-[16.6%]">Status</th>
              </tr>
            </thead>
            
            <tbody className="divide-y divide-zinc-800/50">
              {/* Map over displayedOrders instead of filteredOrders */}
              {displayedOrders.map((order) => (
                <tr key={order.id} className="hover:bg-[#18181b]/50 transition-colors">
                  <td className="px-6 py-4 text-brand font-medium text-sm">{order.id}</td>
                  <td className="px-6 py-4 text-zinc-200 text-sm">{order.customer}</td>
                  <td className="px-6 py-4 text-zinc-400 text-sm">{order.seller}</td>
                  <td className="px-6 py-4 text-zinc-200 text-sm">${order.amount.toFixed(2)}</td>
                  <td className="px-6 py-4 text-zinc-400 text-sm">{order.date}</td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium border ${getStatusBadge(order.status)}`}>
                      <span className={`w-1.5 h-1.5 rounded-full ${getStatusDot(order.status)}`}></span>
                      {order.status}
                    </span>
                  </td>
                </tr>
              ))}
              
              {filteredOrders.length === 0 && (
                <tr>
                  <td colSpan="6" className="px-6 py-8 text-center text-zinc-500 text-sm">
                    No {activeTab.toLowerCase()} orders found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        <div className="px-6 py-4 border-t border-zinc-800 flex flex-col sm:flex-row justify-between items-center gap-4 text-sm">
          
          <div className="text-zinc-500">
            {/* These variables now perfectly track what is physically on the screen vs what is in the current tab */}
            Showing <span className="text-white font-medium">{displayedOrders.length}</span> of <span className="text-white font-medium">{filteredOrders.length}</span> results
          </div>
          
          <div className="flex items-center gap-4">
            {/* The dropdown now controls the itemsPerPage state */}
            <select 
              className="bg-[#09090b] text-zinc-200 border border-zinc-800 rounded-lg px-3 py-1.5 focus:outline-none focus:border-brand text-sm cursor-pointer"
              value={itemsPerPage}
              onChange={(e) => setItemsPerPage(Number(e.target.value))}
            >
              <option value={10}>10 per page</option>
              <option value={25}>25 per page</option>
              <option value={50}>50 per page</option>
            </select>
            
            <div className="flex gap-2">
              <button className="p-1.5 rounded-lg border border-zinc-800 bg-[#09090b] text-zinc-400 hover:text-white hover:bg-zinc-800 transition-colors" title="Previous Page">
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button className="p-1.5 rounded-lg border border-zinc-800 bg-[#09090b] text-zinc-400 hover:text-white hover:bg-zinc-800 transition-colors" title="Next Page">
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>

      </div>
    </div>
  );
};

export default OrderManagement;