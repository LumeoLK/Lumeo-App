import React, { useState } from 'react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Trash2, MessageCircle } from 'lucide-react';
export function CustomRequests() {
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const requests = Array.from({
    length: 9
  }).map((_, i) => ({
    id: i + 1,
    image: `https://images.unsplash.com/photo-${['1586023492125-27b2c045efd7', '1550226891-ef816aed4a98', '1567538090134-81d278675849'][i % 3]}?w=400&h=300&fit=crop`,
    budget: `$${500 + i * 100} - $${1000 + i * 100}`,
    description:
    'Looking for a custom solid wood dining table with industrial metal legs. Similar to the reference image but darker wood.',
    bids: 12 + i
  }));
  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {requests.map((req) =>
        <Card key={req.id} padding="none" className="flex flex-col h-full">
            <div className="h-48 overflow-hidden relative">
              <img
              src={req.image}
              alt="Reference"
              className="w-full h-full object-cover transition-transform hover:scale-105 duration-500" />

              <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-4">
                <p className="text-white font-bold text-lg">{req.budget}</p>
              </div>
            </div>
            <div className="p-4 flex-1 flex flex-col">
              <p className="text-gray-300 text-sm mb-4 line-clamp-2 flex-1">
                {req.description}
              </p>
              <div className="flex items-center justify-between pt-4 border-t border-dark-border">
                <div className="flex items-center text-brand-accent text-sm font-medium">
                  <MessageCircle className="h-4 w-4 mr-2" />
                  {req.bids} bids received
                </div>
                <Button
                variant="ghost"
                size="sm"
                className="text-status-danger hover:text-status-danger hover:bg-status-danger/10"
                icon={<Trash2 className="h-4 w-4" />}
                onClick={() => setDeleteId(req.id)} />

              </div>
            </div>
          </Card>
        )}
      </div>

      <Modal
        isOpen={!!deleteId}
        onClose={() => setDeleteId(null)}
        title="Delete Request"
        footer={
        <>
            <Button variant="secondary" onClick={() => setDeleteId(null)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={() => setDeleteId(null)}>
              Delete
            </Button>
          </>
        }>

        <p className="text-gray-300">
          Are you sure you want to delete this custom request? All associated
          bids will also be removed.
        </p>
      </Modal>
    </div>);

}