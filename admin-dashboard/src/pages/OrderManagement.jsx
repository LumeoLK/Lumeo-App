import React, { useState, useEffect } from 'react';
import { ChevronLeft, ChevronRight, RefreshCw, Trash2 } from 'lucide-react';

const tabs = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

const OrderManagement = () => {
  const [activeTab, setActiveTab] = useState('All');
  const [itemsPerPage, setItemsPerPage] = useState(10);
  const [currentPage, setCurrentPage] = useState(1);
  
  // Real data states
  const [orders, setOrders] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  // Fetch orders on load
  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    setIsLoading(true);
    try {
      const response = await fetch('http://localhost:5000/api/admin/orders');
      if (response.ok) {
        const data = await response.json();
        setOrders(data);
      }
    } catch (error) {
      console.error("Failed to fetch orders:", error);
    } finally {
      setIsLoading(false);
    }
  };

  // Update Order Status via the API
  const handleStatusChange = async (orderId, newStatus) => {
    try {
      const response = await fetch(`http://localhost:5000/api/admin/orders/${orderId}/status`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus.toLowerCase() })
      });

      if (response.ok) {
        // Update UI instantly
        setOrders(orders.map(order => 
          order._id === orderId ? { ...order, status: newStatus.toLowerCase() } : order
        ));
      }
    } catch (error) {
      console.error("Error updating order status:", error);
    }
  };

  // Delete Order via API
  const handleDeleteOrder = async (orderId) => {
    if (!window.confirm("Are you sure you want to permanently delete this order?")) return;
    
    try {
      const response = await fetch(`http://localhost:5000/api/admin/orders/${orderId}`, {
        method: 'DELETE'
      });
      if (response.ok) {
        setOrders(orders.filter(order => order._id !== orderId));
      }
    } catch (error) {
      console.error("Error deleting order:", error);
    }
  };

  // Format Status for UI
  const capitalize = (str) => str ? str.charAt(0).toUpperCase() + str.slice(1) : '';

  // 1. Filter by the active tab
  const filteredOrders = activeTab === 'All' 
    ? orders 
    : orders.filter(order => capitalize(order.status) === activeTab);

  // 2. Pagination Logic
  const startIndex = (currentPage - 1) * itemsPerPage;
  const displayedOrders = filteredOrders.slice(startIndex, startIndex + itemsPerPage);

  // Styling Helpers
  const getStatusBadge = (status) => {
    switch (capitalize(status)) {
      case 'Pending': return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20';
      case 'Processing': return 'bg-blue-500/10 text-blue-500 border-blue-500/20';
      case 'Shipped': return 'bg-purple-500/10 text-purple-500 border-purple-500/20';
      case 'Delivered': return 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20';
      case 'Cancelled': return 'bg-red-500/10 text-red-500 border-red-500/20';
      default: return 'bg-zinc-500/10 text-zinc-500 border-zinc-500/20';
    }
  };

  const getStatusDot = (status) => {
    switch (capitalize(status)) {
      case 'Pending': return 'bg-yellow-500';
      case 'Processing': return 'bg-blue-500';
      case 'Shipped': return 'bg-purple-500';
      case 'Delivered': return 'bg-emerald-500';
      case 'Cancelled': return 'bg-red-500';
      default: return 'bg-zinc-500';
    }
  };

  // Helper to extract seller name cleanly
  const getSellerName = (order) => {
    if (!order.items || order.items.length === 0) return 'Unknown';
    if (order.items.length > 1) return 'Multiple Shops';
    // If you populated the seller inside the product, you would access it here.
    // For now, we'll return the product title or a generic fallback
    return order.items[0]?.productId?.title || 'Custom Request';
  };

  return (
    <div className="w-full space-y-6">
      
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-white tracking-wide">Order Management</h1>
        <button 
          onClick={fetchOrders}
          disabled={isLoading}
          className="flex items-center gap-2 bg-[#111111] border border-zinc-800 text-zinc-300 px-4 py-2 rounded-xl text-sm hover:bg-zinc-800 transition-colors disabled:opacity-50"
        >
          <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
          {isLoading ? 'Syncing...' : 'Sync Orders'}
        </button>
      </div>

      <div className="flex gap-8 border-b border-zinc-800 overflow-x-auto">
        {tabs.map((tab) => (
          <button
            key={tab}
            onClick={() => { setActiveTab(tab); setCurrentPage(1); }}
            className={`pb-4 text-sm font-medium transition-colors relative whitespace-nowrap ${
              activeTab === tab ? 'text-brand' : 'text-zinc-500 hover:text-zinc-300'
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
          <table className="w-full text-left border-collapse min-w-[800px]">
            
            <thead>
              <tr className="border-b border-zinc-800 text-zinc-400 text-xs font-bold uppercase tracking-wider">
                <th className="px-6 py-5 w-[15%] text-brand">Order ID</th>
                <th className="px-6 py-5 w-[20%]">Customer</th>
                <th className="px-6 py-5 w-[20%]">Item Info</th>
                <th className="px-6 py-5 w-[15%]">Amount</th>
                <th className="px-6 py-5 w-[15%]">Date</th>
                <th className="px-6 py-5 w-[15%]">Status</th>
              </tr>
            </thead>
            
            <tbody className="divide-y divide-zinc-800/50">
              {isLoading ? (
                <tr>
                  <td colSpan="6" className="px-6 py-8 text-center text-zinc-500 text-sm">Loading platform orders...</td>
                </tr>
              ) : displayedOrders.length === 0 ? (
                <tr>
                  <td colSpan="6" className="px-6 py-8 text-center text-zinc-500 text-sm">No {activeTab.toLowerCase()} orders found.</td>
                </tr>
              ) : (
                displayedOrders.map((order) => (
                  <tr key={order._id} className="hover:bg-[#18181b]/50 transition-colors group">
                    {/* Shortened Order ID */}
                    <td className="px-6 py-4 text-brand font-medium text-sm">
                      #ORD-{order._id.slice(-6).toUpperCase()}
                    </td>
                    
                    {/* Customer Name */}
                    <td className="px-6 py-4 text-zinc-200 text-sm">
                      {order.buyerId?.name || 'Unknown User'}
                    </td>
                    
                    {/* Seller/Item Info */}
                    <td className="px-6 py-4 text-zinc-400 text-sm truncate max-w-[150px]">
                      {getSellerName(order)}
                    </td>
                    
                    {/* Amount */}
                    <td className="px-6 py-4 text-zinc-200 text-sm font-medium">
                      Rs. {order.totalAmount?.toFixed(2)}
                    </td>
                    
                    {/* Date */}
                    <td className="px-6 py-4 text-zinc-400 text-sm">
                      {new Date(order.createdAt).toLocaleDateString()}
                    </td>
                    
                    {/* Interactive Status Dropdown */}
                    <td className="px-6 py-4 flex items-center gap-2">
                      <div className="relative inline-block">
                        <select 
                          className={`appearance-none outline-none cursor-pointer inline-flex items-center gap-1.5 px-3 py-1 pr-8 rounded-full text-xs font-medium border transition-colors ${getStatusBadge(order.status)}`}
                          value={capitalize(order.status)}
                          onChange={(e) => handleStatusChange(order._id, e.target.value)}
                        >
                          <option value="Pending">Pending</option>
                          <option value="Processing">Processing</option>
                          <option value="Shipped">Shipped</option>
                          <option value="Delivered">Delivered</option>
                          <option value="Cancelled">Cancelled</option>
                        </select>
                        <div className={`absolute top-1/2 right-2.5 -translate-y-1/2 w-1.5 h-1.5 rounded-full ${getStatusDot(order.status)} pointer-events-none`}></div>
                      </div>
                      
                      {/* Delete Action (Shows on hover) */}
                      <button 
                        onClick={() => handleDeleteOrder(order._id)}
                        className="p-1.5 text-zinc-600 hover:text-red-500 hover:bg-red-500/10 rounded-lg opacity-0 group-hover:opacity-100 transition-all"
                        title="Delete Order"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination Controls */}
        <div className="px-6 py-4 border-t border-zinc-800 flex flex-col sm:flex-row justify-between items-center gap-4 text-sm">
          <div className="text-zinc-500">
            Showing <span className="text-white font-medium">{displayedOrders.length > 0 ? startIndex + 1 : 0}</span> to <span className="text-white font-medium">{startIndex + displayedOrders.length}</span> of <span className="text-white font-medium">{filteredOrders.length}</span> results
          </div>
          
          <div className="flex items-center gap-4">
            <select 
              className="bg-[#09090b] text-zinc-200 border border-zinc-800 rounded-lg px-3 py-1.5 focus:outline-none focus:border-brand text-sm cursor-pointer"
              value={itemsPerPage}
              onChange={(e) => { setItemsPerPage(Number(e.target.value)); setCurrentPage(1); }}
            >
              <option value={10}>10 per page</option>
              <option value={25}>25 per page</option>
              <option value={50}>50 per page</option>
            </select>
            
            <div className="flex gap-2">
              <button 
                onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                disabled={currentPage === 1}
                className="p-1.5 rounded-lg border border-zinc-800 bg-[#09090b] text-zinc-400 hover:text-white hover:bg-zinc-800 transition-colors disabled:opacity-50"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button 
                onClick={() => setCurrentPage(currentPage + 1)}
                disabled={startIndex + itemsPerPage >= filteredOrders.length}
                className="p-1.5 rounded-lg border border-zinc-800 bg-[#09090b] text-zinc-400 hover:text-white hover:bg-zinc-800 transition-colors disabled:opacity-50"
              >
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