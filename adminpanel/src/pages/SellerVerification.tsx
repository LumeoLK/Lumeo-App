import React, { useState } from 'react';
import { Card } from '../components/ui/Card';
import { StatusBadge } from '../components/ui/StatusBadge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { FileImage, ZoomIn, Check, X, ShieldCheck } from 'lucide-react';
import { motion } from 'framer-motion';
import { cn } from '../lib/utils';
interface Applicant {
  id: number;
  name: string;
  shopName: string;
  dateApplied: string;
  status: 'pending' | 'approved' | 'rejected';
  email: string;
  phone: string;
  address: string;
  businessType: string;
  documents: {
    nicFront: string;
    nicBack: string;
    br: string;
    shopPhoto: string;
  };
}
const mockApplicants: Applicant[] = [
{
  id: 1,
  name: 'Kasun Perera',
  shopName: 'Colombo Woodworks',
  dateApplied: '2023-10-24',
  status: 'pending',
  email: 'kasun@colombowood.lk',
  phone: '+94 77 123 4567',
  address: '123 Galle Road, Colombo 03',
  businessType: 'Sole Proprietorship',
  documents: {
    nicFront: '',
    nicBack: '',
    br: '',
    shopPhoto: ''
  }
},
{
  id: 2,
  name: 'Amara Silva',
  shopName: 'Kandy Cane Furniture',
  dateApplied: '2023-10-23',
  status: 'pending',
  email: 'amara@kandycane.lk',
  phone: '+94 71 987 6543',
  address: '45 Peradeniya Rd, Kandy',
  businessType: 'Partnership',
  documents: {
    nicFront: '',
    nicBack: '',
    br: '',
    shopPhoto: ''
  }
},
{
  id: 3,
  name: 'Mohamed Fazil',
  shopName: 'Fazil Modern Home',
  dateApplied: '2023-10-22',
  status: 'pending',
  email: 'fazil@modernhome.lk',
  phone: '+94 76 555 1234',
  address: '89 Main Street, Galle',
  businessType: 'Private Limited',
  documents: {
    nicFront: '',
    nicBack: '',
    br: '',
    shopPhoto: ''
  }
},
// Add more mock data as needed
...Array.from({
  length: 5
}).map((_, i) => ({
  id: i + 4,
  name: `Applicant ${i + 4}`,
  shopName: `Shop ${i + 4}`,
  dateApplied: '2023-10-20',
  status: 'pending' as const,
  email: `applicant${i + 4}@example.com`,
  phone: '+94 77 000 0000',
  address: '123 Street, City',
  businessType: 'Sole Proprietorship',
  documents: {
    nicFront: '',
    nicBack: '',
    br: '',
    shopPhoto: ''
  }
}))];

export function SellerVerification() {
  const [selectedId, setSelectedId] = useState<number>(mockApplicants[0].id);
  const [isRejectModalOpen, setIsRejectModalOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [previewImage, setPreviewImage] = useState<string | null>(null);
  const selectedApplicant =
  mockApplicants.find((a) => a.id === selectedId) || mockApplicants[0];
  return (
    <div className="h-[calc(100vh-8rem)] flex flex-col">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-bold text-white flex items-center gap-2">
          Seller Verification Requests
          <span className="bg-brand-accent text-brand-primary text-xs font-bold px-2 py-0.5 rounded-full">
            {mockApplicants.length}
          </span>
        </h2>
      </div>

      <div className="flex-1 flex flex-col lg:flex-row gap-6 overflow-hidden">
        {/* Left List Panel */}
        <div className="w-full lg:w-[400px] flex flex-col bg-dark-surface border border-dark-border rounded-xl overflow-hidden">
          <div className="p-4 border-b border-dark-border bg-dark-surface">
            <input
              type="text"
              placeholder="Search applicants..."
              className="w-full bg-dark-bg border border-dark-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-brand-accent" />

          </div>
          <div className="flex-1 overflow-y-auto custom-scrollbar">
            {mockApplicants.map((applicant) =>
            <div
              key={applicant.id}
              onClick={() => setSelectedId(applicant.id)}
              className={cn(
                'p-4 border-b border-dark-border cursor-pointer transition-colors hover:bg-dark-hover relative',
                selectedId === applicant.id ? 'bg-brand-accent/5' : ''
              )}>

                {selectedId === applicant.id &&
              <div className="absolute left-0 top-0 bottom-0 w-1 bg-brand-accent" />
              }
                <div className="flex justify-between items-start mb-1">
                  <h4
                  className={cn(
                    'font-medium',
                    selectedId === applicant.id ?
                    'text-brand-accent' :
                    'text-white'
                  )}>

                    {applicant.shopName}
                  </h4>
                  <span className="text-xs text-gray-500">
                    {applicant.dateApplied}
                  </span>
                </div>
                <p className="text-sm text-gray-400 mb-2">{applicant.name}</p>
                <StatusBadge status={applicant.status} />
              </div>
            )}
          </div>
        </div>

        {/* Right Detail Panel */}
        <div className="flex-1 flex flex-col bg-dark-surface border border-dark-border rounded-xl overflow-hidden relative">
          {/* Header */}
          <div className="p-6 border-b border-dark-border">
            <div className="flex justify-between items-start">
              <div>
                <h1 className="text-2xl font-bold text-white mb-1">
                  {selectedApplicant.shopName}
                </h1>
                <p className="text-gray-400 flex items-center gap-2">
                  <ShieldCheck className="h-4 w-4 text-brand-accent" />
                  {selectedApplicant.name}
                </p>
              </div>
              <StatusBadge
                status={selectedApplicant.status}
                className="text-sm px-3 py-1" />

            </div>
          </div>

          {/* Scrollable Content */}
          <div className="flex-1 overflow-y-auto p-6 custom-scrollbar">
            {/* Documents Grid */}
            <section className="mb-8">
              <h3 className="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-4">
                Submitted Documents
              </h3>
              <div className="grid grid-cols-2 gap-4">
                {[
                'NIC Front',
                'NIC Back',
                'Business Registration',
                'Shop Photo'].
                map((doc, i) =>
                <Card
                  key={i}
                  className="aspect-video flex flex-col items-center justify-center bg-dark-bg border-dashed border-dark-border group hover:border-brand-accent/50 cursor-pointer transition-colors"
                  padding="none"
                  onClick={() => setPreviewImage(doc)}>

                    <div className="w-12 h-12 rounded-full bg-dark-surface flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
                      <FileImage className="h-6 w-6 text-gray-500 group-hover:text-brand-accent" />
                    </div>
                    <span className="text-sm text-gray-400 group-hover:text-white">
                      {doc}
                    </span>
                    <span className="text-xs text-brand-accent mt-1 opacity-0 group-hover:opacity-100 flex items-center gap-1">
                      <ZoomIn className="h-3 w-3" /> Click to preview
                    </span>
                  </Card>
                )}
              </div>
            </section>

            {/* Applicant Info Grid */}
            <section>
              <h3 className="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-4">
                Applicant Information
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {[
                {
                  label: 'Full Name',
                  value: selectedApplicant.name
                },
                {
                  label: 'Email Address',
                  value: selectedApplicant.email
                },
                {
                  label: 'Phone Number',
                  value: selectedApplicant.phone
                },
                {
                  label: 'Business Address',
                  value: selectedApplicant.address
                },
                {
                  label: 'Business Type',
                  value: selectedApplicant.businessType
                },
                {
                  label: 'Application Date',
                  value: selectedApplicant.dateApplied
                }].
                map((field, i) =>
                <div
                  key={i}
                  className="bg-dark-bg border border-dark-border rounded-lg p-4">

                    <label className="block text-xs text-gray-500 mb-1">
                      {field.label}
                    </label>
                    <p className="text-white font-medium">{field.value}</p>
                  </div>
                )}
              </div>
            </section>
          </div>

          {/* Sticky Action Bar */}
          <div className="p-4 bg-dark-surface border-t border-dark-border flex justify-between items-center">
            <span className="text-sm text-gray-400">
              Status:{' '}
              <span className="text-status-warning font-medium">
                Pending Review
              </span>
            </span>
            <div className="flex gap-3">
              <Button
                variant="destructive"
                icon={<X className="h-4 w-4" />}
                onClick={() => setIsRejectModalOpen(true)}>

                Reject
              </Button>
              <Button
                variant="primary"
                icon={<Check className="h-4 w-4" />}
                onClick={() => {}}>

                Approve Application
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Reject Modal */}
      <Modal
        isOpen={isRejectModalOpen}
        onClose={() => setIsRejectModalOpen(false)}
        title="Reject Application"
        footer={
        <>
            <Button
            variant="secondary"
            onClick={() => setIsRejectModalOpen(false)}>

              Cancel
            </Button>
            <Button
            variant="destructive"
            onClick={() => setIsRejectModalOpen(false)}>

              Confirm Rejection
            </Button>
          </>
        }>

        <div className="space-y-4">
          <p className="text-gray-300">
            Please provide a reason for rejecting this application. This will be
            sent to the applicant.
          </p>
          <textarea
            value={rejectReason}
            onChange={(e) => setRejectReason(e.target.value)}
            className="w-full h-32 bg-dark-bg border border-dark-border rounded-lg p-3 text-white focus:outline-none focus:border-brand-accent resize-none"
            placeholder="e.g. Business registration document is unclear..." />

        </div>
      </Modal>

      {/* Image Preview Modal */}
      <Modal
        isOpen={!!previewImage}
        onClose={() => setPreviewImage(null)}
        title="Document Preview"
        size="lg">

        <div className="aspect-video bg-dark-bg rounded-lg flex items-center justify-center border border-dark-border">
          <div className="text-center">
            <FileImage className="h-16 w-16 text-gray-600 mx-auto mb-4" />
            <p className="text-gray-400">Preview for {previewImage}</p>
            <p className="text-xs text-gray-600 mt-2">(Placeholder Image)</p>
          </div>
        </div>
      </Modal>
    </div>);

}