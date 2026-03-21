import React, { useState } from 'react';
import { Search, RefreshCw, EyeOff, Trash2, ChevronLeft, ChevronRight } from 'lucide-react';

// Dummy data for Lumeo furniture products
const initialProducts = [
  { id: 1, name: 'Modern Sofa 1', category: 'Living Room', price: 153.40, stock: 1, arStatus: 'Pending', image: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=100&h=100&fit=crop' },
  { id: 2, name: 'Oak Dining Table 2', category: 'Dining', price: 260.72, stock: 14, arStatus: 'Processing', image: 'https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=100&h=100&fit=crop' },
  { id: 3, name: 'Office Chair 3', category: 'Office', price: 180.16, stock: 34, arStatus: 'Live', image: 'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?w=100&h=100&fit=crop' },
  { id: 4, name: 'Bed Frame 4', category: 'Bedroom', price: 284.43, stock: 18, arStatus: 'Failed', image: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=100&h=100&fit=crop' },
  { id: 5, name: 'Bookshelf 5', category: 'Storage', price: 455.16, stock: 24, arStatus: 'Pending', image: 'https://images.unsplash.com/photo-1594620302200-9a762244a156?w=100&h=100&fit=crop' },
  { id: 6, name: 'Modern Sofa 6', category: 'Living Room', price: 368.68, stock: 20, arStatus: 'Processing', image: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=100&h=100&fit=crop' },
];

const ProductManagement = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('All Categories');

  // Helper function to render the correct AR status badge styling
  const getArStatusBadge = (status) => {
    switch (status) {
      case 'Pending':
        return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20';
      case 'Processing':
        return 'bg-blue-500/10 text-blue-500 border-blue-500/20';
      case 'Live':
        return 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20';
      case 'Failed':
        return 'bg-red-500/10 text-red-500 border-red-500/20';
      default:
        return 'bg-zinc-500/10 text-zinc-500 border-zinc-500/20';
    }
  };

  // Helper function to render the dot color for the AR status badge
  const getArStatusDot = (status) => {
    switch (status) {
      case 'Pending': return 'bg-yellow-500';
      case 'Processing': return 'bg-blue-500';
      case 'Live': return 'bg-emerald-500';
      case 'Failed': return 'bg-red-500';
      default: return 'bg-zinc-500';
    }
  };

  return (
    <div className="w-full space-y-6">
      
      {/* Header Section */}
      <div>
        <h1 className="text-2xl font-bold text-white tracking-wide">Product Management</h1>
       
      </div>

      {/* Toolbar: Search, Filter, and Sync Button */}
      <div className="flex flex-col sm:flex-row justify-between items-center gap-4 bg-[#111111] p-4 rounded-2xl border border-zinc-800">
        <div className="flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
          {/* Search Bar */}
          <div className="relative w-full sm:w-64">
            <Search className="w-5 h-5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
            <input 
              type="text" 
              placeholder="Search..." 
              className="w-full bg-[#09090b] text-zinc-200 pl-10 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm transition-colors"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          {/* Category Dropdown */}
          <select 
            className="bg-[#09090b] text-zinc-200 px-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-brand text-sm appearance-none min-w-[160px]"
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
          >
            <option value="All Categories">All Categories</option>
            <option value="Living Room">Living Room</option>
            <option value="Bedroom">Bedroom</option>
            <option value="Dining">Dining</option>
            <option value="Office">Office</option>
            <option value="Storage">Storage</option>
          </select>
        </div>

        {/* Sync Button */}
        <button className="flex items-center gap-2 bg-brand text-black px-5 py-2.5 rounded-xl font-bold text-sm hover:bg-brand/90 transition-colors w-full sm:w-auto justify-center">
          <RefreshCw className="w-4 h-4" />
          Sync Products
        </button>
      </div>

      {/* Products Table */}
      <div className="bg-[#111111] rounded-2xl border border-zinc-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            
            {/* Table Header */}
            <thead>
              <tr className="border-b border-zinc-800 text-zinc-400 text-xs font-bold uppercase tracking-wider">
                {/* Product gets 30% of the width */}
                <th className="px-6 py-5 w-[30%]">Product</th>
                
                {/* The rest get exactly 14% each for perfectly equal spacing */}
                <th className="px-6 py-5 w-[14%]">Category</th>
                <th className="px-6 py-5 text-brand w-[14%]">Price</th>
                <th className="px-6 py-5 w-[14%]">Stock</th>
                <th className="px-6 py-5 w-[14%]">AR Status</th>
                <th className="px-6 py-5 text-right w-[14%]">Actions</th>
              </tr>
            </thead>
            
            {/* Table Body */}
            <tbody className="divide-y divide-zinc-800/50">
              {initialProducts.map((product) => (
                <tr key={product.id} className="hover:bg-[#18181b]/50 transition-colors">
                  
                  {/* Product Image & Name */}
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-4">
                      <img src={product.image} alt={product.name} className="w-12 h-12 rounded-lg object-cover border border-zinc-800" />
                      <span className="text-zinc-200 font-semibold">{product.name}</span>
                    </div>
                  </td>
                  
                  {/* Category */}
                  <td className="px-6 py-4 text-zinc-400 text-sm">
                    {product.category}
                  </td>
                  
                  {/* Price */}
                  <td className="px-6 py-4 text-brand font-medium">
                    ${product.price.toFixed(2)}
                  </td>

                  {/* Stock */}
                  <td className="px-6 py-4 text-zinc-300">
                    {product.stock}
                  </td>
                  
                  {/* AR Status Badge */}
                  <td className="px-6 py-4">
                    <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium border ${getArStatusBadge(product.arStatus)}`}>
                      <span className={`w-1.5 h-1.5 rounded-full ${getArStatusDot(product.arStatus)}`}></span>
                      {product.arStatus}
                    </span>
                  </td>
                  
                  {/* Actions: Hide and Delete Only */}
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-3">
                      <button className="p-2 text-zinc-500 hover:text-zinc-300 hover:bg-zinc-800 rounded-lg transition-colors" title="Hide Product">
                        <EyeOff className="w-4 h-4" />
                      </button>
                      <button className="p-2 text-zinc-500 hover:text-red-500 hover:bg-red-500/10 rounded-lg transition-colors" title="Delete Product">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                  
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="px-6 py-4 border-t border-zinc-800 flex flex-col sm:flex-row justify-between items-center gap-4 text-sm">
          
          {/* Results Counter */}
          <div className="text-zinc-500">
            Showing <span className="text-white font-medium">1</span> to <span className="text-white font-medium">10</span> of <span className="text-white font-medium">15</span> results
          </div>
          
          {/* Controls */}
          <div className="flex items-center gap-4">
            
            {/* Rows per page dropdown */}
            <select className="bg-[#09090b] text-zinc-200 border border-zinc-800 rounded-lg px-3 py-1.5 focus:outline-none focus:border-brand text-sm cursor-pointer">
              <option>10 per page</option>
              <option>25 per page</option>
              <option>50 per page</option>
            </select>
            
            {/* Next/Prev Buttons */}
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

export default ProductManagement;