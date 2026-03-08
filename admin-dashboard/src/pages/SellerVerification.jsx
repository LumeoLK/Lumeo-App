import React, { useState } from 'react';
import { Search, ShieldCheck, Check, X, FileImage } from 'lucide-react';

// Dummy data matching your Sri Lankan furniture stores
const applicants = [
  {
    id: 1,
    storeName: 'Colombo Woodworks',
    applicant: 'Kasun Perera',
    date: '2023-10-24',
    status: 'Pending',
    email: 'kasun@colombowood.lk',
    phone: '+94 77 123 4567',
    address: '123 Galle Road, Colombo 03',
    businessType: 'Sole Proprietorship',
    documents: ['NIC Front', 'NIC Back', 'Business Registration', 'Bank Statement']
  },
  {
    id: 2,
    storeName: 'Kandy Cane Furniture',
    applicant: 'Amara Silva',
    date: '2023-10-23',
    status: 'Pending',
    email: 'amara@kandycane.lk',
    phone: '+94 71 987 6543',
    address: '45 Dalada Vidiya, Kandy',
    businessType: 'Partnership',
    documents: ['NIC Front', 'NIC Back']
  },
  {
    id: 3,
    storeName: 'Fazil Modern Home',
    applicant: 'Mohamed Fazil',
    date: '2023-10-22',
    status: 'Pending',
    email: 'contact@fazilmodern.lk',
    phone: '+94 76 555 1234',
    address: '88 Main Street, Galle',
    businessType: 'Private Limited',
    documents: ['NIC Front', 'NIC Back', 'BR Certificate']
  },
  {
    id: 4,
    storeName: 'Shop 4',
    applicant: 'Applicant 4',
    date: '2023-10-20',
    status: 'Pending',
    email: 'shop4@example.com',
    phone: '+94 70 000 0000',
    address: 'Placeholder Address',
    businessType: 'Sole Proprietorship',
    documents: ['NIC Front']
  }
];

const SellerVerification = () => {
  const [searchTerm, setSearchTerm] = useState('');
  // State to track which applicant is actively being viewed (defaults to the first one)
  const [selectedId, setSelectedId] = useState(applicants[0].id);

  // Find the full details of the currently selected applicant
  const selectedSeller = applicants.find(app => app.id === selectedId);

  return (
    <div className="w-full flex flex-col h-[calc(100vh-6rem)]">
      
      {/* Page Header */}
      <div className="flex items-center gap-3 mb-6">
        <h1 className="text-2xl font-bold text-white tracking-wide">Seller Verification Requests</h1>
        <span className="bg-brand text-black text-xs font-bold px-2 py-0.5 rounded-full">
          {applicants.length}
        </span>
      </div>

      {/* Main Split Layout */}
      <div className="flex gap-6 flex-1 min-h-0">
        
        {/* LEFT COLUMN: Applicant List */}
        <div className="w-[350px] bg-[#111111] border border-zinc-800 rounded-2xl flex flex-col overflow-hidden">
          
          {/* Search Bar Container - Fixed at top */}
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

          {/* Scrollable List */}
          <div className="flex-1 overflow-y-auto">
            {applicants.map((seller) => (
              <button
                key={seller.id}
                onClick={() => setSelectedId(seller.id)}
                className={`w-full text-left p-5 border-b border-zinc-800/50 transition-colors flex flex-col gap-2
                  ${selectedId === seller.id 
                    ? 'bg-[#18181b] border-l-4 border-l-brand' // Active state uses your brand color
                    : 'hover:bg-[#18181b]/50 border-l-4 border-l-transparent'
                  }`}
              >
                <div className="flex justify-between items-start">
                  <h3 className={`font-semibold ${selectedId === seller.id ? 'text-white' : 'text-zinc-200'}`}>
                    {seller.storeName}
                  </h3>
                  <span className="text-zinc-500 text-xs">{seller.date}</span>
                </div>
                
                <p className="text-zinc-400 text-sm">{seller.applicant}</p>
                
                <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full border border-brand/20 bg-brand/10 text-brand text-xs font-medium w-fit mt-1">
                  <span className="w-1.5 h-1.5 rounded-full bg-brand"></span>
                  {seller.status}
                </span>
              </button>
            ))}
          </div>
        </div>

        {/* RIGHT COLUMN: Selected Applicant Details */}
        {selectedSeller && (
          <div className="flex-1 bg-[#111111] border border-zinc-800 rounded-2xl flex flex-col overflow-hidden">
            
            {/* Header - Fixed */}
            <div className="p-8 border-b border-zinc-800 flex justify-between items-start">
              <div>
                <h2 className="text-2xl font-bold text-white mb-2">{selectedSeller.storeName}</h2>
                <div className="flex items-center gap-2 text-zinc-400">
                  <ShieldCheck className="w-4 h-4 text-brand" />
                  <span>{selectedSeller.applicant}</span>
                </div>
              </div>
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full border border-brand/20 bg-brand/10 text-brand text-sm font-medium">
                <span className="w-1.5 h-1.5 rounded-full bg-brand"></span>
                {selectedSeller.status}
              </span>
            </div>

            {/* Content Body - Scrollable */}
            <div className="flex-1 overflow-y-auto p-8 space-y-10">
              
              {/* Documents Section */}
              <div>
                <h3 className="text-xs font-bold text-zinc-500 uppercase tracking-wider mb-4">Submitted Documents</h3>
                <div className="grid grid-cols-2 gap-4">
                  {selectedSeller.documents.map((doc, idx) => (
                    <div key={idx} className="h-40 rounded-xl border-2 border-dashed border-zinc-800 flex flex-col items-center justify-center text-zinc-500 hover:border-zinc-600 hover:text-zinc-300 transition-colors cursor-pointer bg-[#09090b]/50">
                      <FileImage className="w-8 h-8 mb-3 opacity-50" />
                      <span className="text-sm font-medium">{doc}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Information Section */}
              <div>
                <h3 className="text-xs font-bold text-zinc-500 uppercase tracking-wider mb-4">Applicant Information</h3>
                <div className="grid grid-cols-2 gap-4">
                  
                  {/* Info Cards */}
                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Full Name</p>
                    <p className="text-white font-medium">{selectedSeller.applicant}</p>
                  </div>
                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Email Address</p>
                    <p className="text-white font-medium">{selectedSeller.email}</p>
                  </div>
                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Phone Number</p>
                    <p className="text-white font-medium">{selectedSeller.phone}</p>
                  </div>
                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Business Address</p>
                    <p className="text-white font-medium">{selectedSeller.address}</p>
                  </div>
                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Business Type</p>
                    <p className="text-white font-medium">{selectedSeller.businessType}</p>
                  </div>
                  <div className="bg-[#09090b] p-4 rounded-xl border border-zinc-800/50">
                    <p className="text-zinc-500 text-xs mb-1">Application Date</p>
                    <p className="text-white font-medium">{selectedSeller.date}</p>
                  </div>

                </div>
              </div>
            </div>

            {/* Footer Actions - Fixed */}
            <div className="p-6 border-t border-zinc-800 bg-[#09090b]/50 flex justify-between items-center">
              <p className="text-sm font-medium text-zinc-400">
                Status: <span className="text-brand">Pending Review</span>
              </p>
              
              <div className="flex gap-3">
                <button className="flex items-center gap-2 px-6 py-2.5 rounded-xl border border-red-500/20 text-red-500 hover:bg-red-500/10 font-medium text-sm transition-colors">
                  <X className="w-4 h-4" />
                  Reject
                </button>
                <button className="flex items-center gap-2 px-6 py-2.5 rounded-xl bg-[#FBB040] text-black hover:bg-[#FBB040]/90 font-bold text-sm transition-colors">
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