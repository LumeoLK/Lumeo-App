import React, { useState, useEffect } from 'react';
import { Search, ShieldCheck, Check, X, FileImage, User as UserIcon } from 'lucide-react';

const SellerVerification = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [applicants, setApplicants] = useState([]);
  const [selectedId, setSelectedId] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  // Fetch pending sellers from the backend
  useEffect(() => {
    fetchPendingSellers();
  }, []);

  const fetchPendingSellers = async () => {
    try {
      // Corrected syntax here
      const response = await fetch(`${import.meta.env.VITE_BACKEND_URL}/api/admin/sellers/pending`);
      const data = await response.json();
      setApplicants(data);
      if (data.length > 0) {
        setSelectedId(data[0]._id);
      }
      setIsLoading(false);
    } catch (error) {
      console.error("Failed to fetch sellers:", error);
      setIsLoading(false);
    }
  };

  const handleApprove = async (id) => {
    try {
      // Replaced localhost with environment variable
      const response = await fetch(`${import.meta.env.VITE_BACKEND_URL}/api/admin/sellers/${id}/approve`, { method: 'PUT' });
      if (response.ok) {
        const updatedList = applicants.filter(app => app._id !== id);
        setApplicants(updatedList);
        setSelectedId(updatedList.length > 0 ? updatedList[0]._id : null);
      }
    } catch (error) {
      console.error("Error approving seller", error);
    }
  };

  const handleReject = async (id) => {
    try {
      const response = await fetch(`${import.meta.env.VITE_BACKEND_URL}/api/admin/sellers/${id}/reject`, { method: 'DELETE' });
      if (response.ok) {
        const updatedList = applicants.filter(app => app._id !== id);
        setApplicants(updatedList);
        setSelectedId(updatedList.length > 0 ? updatedList[0]._id : null);
      }
    } catch (error) {
      console.error("Error rejecting seller", error);
    }
  };

  const selectedSeller = applicants.find(app => app._id === selectedId);

  const filteredApplicants = applicants.filter(app => 
    app.shopName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    app.displayName?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (isLoading) {
    return <div className="text-white p-8">Loading applicants...</div>;
  }

  return (
    <div className="w-full flex flex-col h-[calc(100vh-6rem)]">
      
      {/* Page Header */}
      <div className="flex items-center gap-3 mb-6">
        <h1 className="text-2xl font-bold text-white tracking-wide">Seller Verification Requests</h1>
        <span className="bg-brand text-black text-xs font-bold px-2 py-0.5 rounded-full">
          {applicants.length}
        </span>
      </div>

      <div className="flex gap-6 flex-1 min-h-0">
        
        {/* LEFT COLUMN: Applicant List */}
        <div className="w-[350px] bg-[#111111] border border-zinc-800 rounded-2xl flex flex-col overflow-hidden">
          <div className="p-4 border-b border-zinc-800/50">
            <div className="relative">
              <input 
                type="text" 
                placeholder="Search applicants..." 
                className="w-full bg-[#09090b] text-zinc-200 pl-4 pr-4 py-2.5 rounded-xl border border-zinc-800 focus:outline-none focus:border-zinc-500 text-sm"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>

          <div className="flex-1 overflow-y-auto">
            {filteredApplicants.length === 0 ? (
              <p className="p-5 text-zinc-500 text-sm">No pending applications.</p>
            ) : (
              filteredApplicants.map((seller) => (
                <button
                  key={seller._id}
                  onClick={() => setSelectedId(seller._id)}
                  className={`w-full text-left p-5 border-b border-zinc-800/50 transition-colors flex flex-col gap-2
                    ${selectedId === seller._id 
                      ? 'bg-[#18181b] border-l-4 border-l-brand'
                      : 'hover:bg-[#18181b]/50 border-l-4 border-l-transparent'
                    }`}
                >
                  <div className="flex justify-between items-start">
                    <h3 className={`font-semibold ${selectedId === seller._id ? 'text-white' : 'text-zinc-200'}`}>
                      {seller.shopName}
                    </h3>
                    <span className="text-zinc-500 text-xs">
                      {new Date(seller.createdAt).toLocaleDateString()}
                    </span>
                  </div>
                  
                  <p className="text-zinc-400 text-sm">{seller.displayName}</p>
                  
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full border border-brand/20 bg-brand/10 text-brand text-xs font-medium w-fit mt-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-brand"></span>
                    Pending
                  </span>
                </button>
              ))
            )}
          </div>
        </div>

        {/* RIGHT COLUMN: Selected Applicant Details */}
        {selectedSeller && (
          <div className="flex-1 bg-[#111111] border border-zinc-800 rounded-2xl flex flex-col overflow-hidden">
            
            {/* Header with Profile Picture (Logo) */}
            <div className="p-8 border-b border-zinc-800 flex justify-between items-center">
              <div className="flex items-center gap-5">
                {/* Display Profile Picture / Logo */}
                {selectedSeller.logo ? (
                  <img src={selectedSeller.logo} alt="Profile" className="w-16 h-16 rounded-full object-cover border border-zinc-700" />
                ) : (
                  <div className="w-16 h-16 rounded-full bg-[#09090b] border border-zinc-800 flex items-center justify-center">
                    <UserIcon className="w-8 h-8 text-zinc-600" />
                  </div>
                )}
                
                <div>
                  <h2 className="text-2xl font-bold text-white mb-1">{selectedSeller.shopName}</h2>
                  <div className="flex items-center gap-2 text-zinc-400">
                    <ShieldCheck className="w-4 h-4 text-brand" />
                    <span>{selectedSeller.displayName}</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Content Body */}
            <div className="flex-1 overflow-y-auto p-8 space-y-10">
              
              {/* Identity Documents Section */}
              <div>
                <h3 className="text-xs font-bold text-zinc-500 uppercase tracking-wider mb-4">Identity Documents</h3>
                <div className="grid grid-cols-2 gap-4">
                  
                  {/* NIC Front */}
                  {selectedSeller.NICfront ? (
                    <div className="rounded-xl border border-zinc-800 overflow-hidden bg-[#09090b]">
                      <p className="text-xs text-zinc-400 p-2 border-b border-zinc-800">ID / NIC (Front Side)</p>
                      <img src={selectedSeller.NICfront} alt="NIC Front" className="w-full h-40 object-cover" />
                    </div>
                  ) : (
                    <div className="h-48 rounded-xl border-2 border-dashed border-zinc-800 flex flex-col items-center justify-center text-zinc-500">
                      <FileImage className="w-8 h-8 mb-2 opacity-50" />
                      <span className="text-sm">No NIC Front Uploaded</span>
                    </div>
                  )}

                  {/* NIC Back */}
                  {selectedSeller.NICback ? (
                    <div className="rounded-xl border border-zinc-800 overflow-hidden bg-[#09090b]">
                      <p className="text-xs text-zinc-400 p-2 border-b border-zinc-800">ID / NIC (Back Side)</p>
                      <img src={selectedSeller.NICback} alt="NIC Back" className="w-full h-40 object-cover" />
                    </div>
                  ) : (
                    <div className="h-48 rounded-xl border-2 border-dashed border-zinc-800 flex flex-col items-center justify-center text-zinc-500">
                      <FileImage className="w-8 h-8 mb-2 opacity-50" />
                      <span className="text-sm">No NIC Back Uploaded</span>
                    </div>
                  )}

                </div>
              </div>

              {/* Information Section (Matched Exactly to Mobile App) */}
              <div>
                <h3 className="text-xs font-bold text-zinc-500 uppercase tracking-wider mb-4">Registration Details</h3>
                <div className="grid grid-cols-2 gap-4">
                  
                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Full Name</p>
                    {/* Maps to fullName if you added it to your schema, or falls back to name */}
                    <p className="text-white font-medium">{selectedSeller.fullName || selectedSeller.userId?.name || 'N/A'}</p>
                  </div>

                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Shop Name</p>
                    <p className="text-white font-medium">{selectedSeller.shopName || 'N/A'}</p>
                  </div>

                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Display Name</p>
                    <p className="text-white font-medium">{selectedSeller.displayName || 'N/A'}</p>
                  </div>

                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Phone Number</p>
                    <p className="text-white font-medium">{selectedSeller.phoneNumber || 'N/A'}</p>
                  </div>

                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Email</p>
                    {/* Appears the mobile app collects email directly. Checks seller doc first, then user doc */}
                    <p className="text-white font-medium">{selectedSeller.email || selectedSeller.userId?.email || 'N/A'}</p>
                  </div>

                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Business Registration Number</p>
                    <p className="text-white font-medium">{selectedSeller.businessRegNumber || 'N/A'}</p>
                  </div>

                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50 col-span-2">
                    <p className="text-zinc-500 text-xs mb-1">Business Address</p>
                    <p className="text-white font-medium">{selectedSeller.businessAddress || 'N/A'}</p>
                  </div>

                </div>
              </div>
            </div>

            {/* Footer Actions */}
            <div className="p-6 border-t border-zinc-800 bg-[#09090b]/50 flex justify-between items-center">
              <p className="text-sm font-medium text-zinc-400">
                Status: <span className="text-brand">Pending Review</span>
              </p>
              
              <div className="flex gap-3">
                <button 
                  onClick={() => handleReject(selectedSeller._id)}
                  className="flex items-center gap-2 px-6 py-2.5 rounded-xl border border-red-500/20 text-red-500 hover:bg-red-500/10 font-medium text-sm transition-colors"
                >
                  <X className="w-4 h-4" />
                  Reject
                </button>
                <button 
                  onClick={() => handleApprove(selectedSeller._id)}
                  className="flex items-center gap-2 px-6 py-2.5 rounded-xl bg-[#FBB040] text-black hover:bg-[#FBB040]/90 font-bold text-sm transition-colors"
                >
                  <Check className="w-4 h-4" />
                  Approve Application
                </button>
              </div>
            </div>

          </div>
        )}
      </div>
    </div>
  );
};

export default SellerVerification;