import React, { useState, useEffect } from 'react';
import { Search, RefreshCw, EyeOff, Trash2, ChevronLeft, ChevronRight, Image as ImageIcon } from 'lucide-react';

const ProductManagement = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('All Categories');
  
  // New state variables for the real database data
  const [products, setProducts] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  // 1. Fetch data when the component loads
  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    setIsLoading(true);
    try {
      const response = await fetch('http://localhost:5000/api/admin/products');
      if (response.ok) {
        const data = await response.json();
        setProducts(data);
      }
    } catch (error) {
      console.error("Failed to fetch products:", error);
    } finally {
      setIsLoading(false);
    }
  };

  // 2. Handle Product Deletion
  const handleDeleteProduct = async (id) => {
    if (!window.confirm("Are you sure you want to permanently delete this product?")) return;

    try {
      const response = await fetch(`http://localhost:5000/api/admin/products/${id}`, {
        method: 'DELETE'
      });
      
      if (response.ok) {
        // Remove it from the screen instantly
        setProducts(products.filter(p => p._id !== id));
      }
    } catch (error) {
      console.error("Error deleting product:", error);
    }
  };

  // Maps your backend DB statuses to your frontend UI text
  const getMappedStatus = (dbStatus) => {
    switch (dbStatus?.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'generating': return 'Processing';
      case 'approved': 
      case 'success': return 'Live';
      case 'failed': return 'Failed';
      default: return 'Pending';
    }
  };

  // Helper function to render the correct AR status badge styling
  const getArStatusBadge = (uiStatus) => {
    switch (uiStatus) {
      case 'Pending': return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20';
      case 'Processing': return 'bg-blue-500/10 text-blue-500 border-blue-500/20';
      case 'Live': return 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20';
      case 'Failed': return 'bg-red-500/10 text-red-500 border-red-500/20';
      default: return 'bg-zinc-500/10 text-zinc-500 border-zinc-500/20';
    }
  };

  // Helper function to render the dot color for the AR status badge
  const getArStatusDot = (uiStatus) => {
    switch (uiStatus) {
      case 'Pending': return 'bg-yellow-500';
      case 'Processing': return 'bg-blue-500';
      case 'Live': return 'bg-emerald-500';
      case 'Failed': return 'bg-red-500';
      default: return 'bg-zinc-500';
    }
  };

  // Filter the REAL products based on search and category
  const filteredProducts = products.filter(product => {
    const matchesSearch = product.title?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = categoryFilter === 'All Categories' || product.category === categoryFilter;
    return matchesSearch && matchesCategory;
  });

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

        {/* Sync Button (Now actually fetches fresh data!) */}
        <button 
          onClick={fetchProducts}
          disabled={isLoading}
          className="flex items-center gap-2 bg-brand text-black px-5 py-2.5 rounded-xl font-bold text-sm hover:bg-brand/90 transition-colors w-full sm:w-auto justify-center disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
          {isLoading ? 'Syncing...' : 'Sync Products'}
        </button>
      </div>

      {/* Products Table */}
      <div className="bg-[#111111] rounded-2xl border border-zinc-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            
            {/* Table Header */}
            <thead>
              <tr className="border-b border-zinc-800 text-zinc-400 text-xs font-bold uppercase tracking-wider">
                <th className="px-6 py-5 w-[30%]">Product</th>
                <th className="px-6 py-5 w-[14%]">Category</th>
                <th className="px-6 py-5 text-brand w-[14%]">Price</th>
                <th className="px-6 py-5 w-[14%]">Stock</th>
                <th className="px-6 py-5 w-[14%]">AR Status</th>
                <th className="px-6 py-5 text-right w-[14%]">Actions</th>
              </tr>
            </thead>
            
            {/* Table Body */}
            <tbody className="divide-y divide-zinc-800/50">
              {isLoading ? (
                <tr>
                  <td colSpan="6" className="px-6 py-8 text-center text-zinc-500">
                    Loading inventory...
                  </td>
                </tr>
              ) : filteredProducts.length === 0 ? (
                <tr>
                  <td colSpan="6" className="px-6 py-8 text-center text-zinc-500">
                    No products found matching your search.
                  </td>
                </tr>
              ) : (
                filteredProducts.map((product) => {
                  const uiStatus = getMappedStatus(product.model3D?.status);
                  
                  return (
                    <tr key={product._id} className="hover:bg-[#18181b]/50 transition-colors">
                      
                      {/* Product Image & Title */}
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-4">
                          {product.images && product.images.length > 0 ? (
                            <img src={product.images[0]} alt={product.title} className="w-12 h-12 rounded-lg object-cover border border-zinc-800" />
                          ) : (
                            <div className="w-12 h-12 rounded-lg bg-[#09090b] border border-zinc-800 flex items-center justify-center">
                              <ImageIcon className="w-5 h-5 text-zinc-600" />
                            </div>
                          )}
                          <span className="text-zinc-200 font-semibold truncate max-w-[200px]" title={product.title}>
                            {product.title}
                          </span>
                        </div>
                      </td>
                      
                      {/* Category */}
                      <td className="px-6 py-4 text-zinc-400 text-sm">
                        {product.category}
                      </td>
                      
                      {/* Price */}
                      <td className="px-6 py-4 text-brand font-medium">
                        Rs. {product.price?.toFixed(2)}
                      </td>

                      {/* Stock */}
                      <td className="px-6 py-4 text-zinc-300">
                        {product.stock}
                      </td>
                      
                      {/* AR Status Badge */}
                      <td className="px-6 py-4">
                        <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium border ${getArStatusBadge(uiStatus)}`}>
                          <span className={`w-1.5 h-1.5 rounded-full ${getArStatusDot(uiStatus)}`}></span>
                          {uiStatus}
                        </span>
                      </td>
                      
                      {/* Actions */}
                      <td className="px-6 py-4 text-right">
                        <div className="flex items-center justify-end gap-3">
                          <button className="p-2 text-zinc-500 hover:text-zinc-300 hover:bg-zinc-800 rounded-lg transition-colors" title="Hide Product">
                            <EyeOff className="w-4 h-4" />
                          </button>
                          <button 
                            onClick={() => handleDeleteProduct(product._id)}
                            className="p-2 text-zinc-500 hover:text-red-500 hover:bg-red-500/10 rounded-lg transition-colors" 
                            title="Delete Product"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                      
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Footer Controls */}
        <div className="px-6 py-4 border-t border-zinc-800 flex flex-col sm:flex-row justify-between items-center gap-4 text-sm">
          <div className="text-zinc-500">
            Showing <span className="text-white font-medium">{filteredProducts.length > 0 ? 1 : 0}</span> to <span className="text-white font-medium">{filteredProducts.length}</span> of <span className="text-white font-medium">{products.length}</span> total products
          </div>
          
          <div className="flex items-center gap-4">
            <select className="bg-[#09090b] text-zinc-200 border border-zinc-800 rounded-lg px-3 py-1.5 focus:outline-none focus:border-brand text-sm cursor-pointer">
              <option>10 per page</option>
              <option>25 per page</option>
              <option>50 per page</option>
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

export default ProductManagement;