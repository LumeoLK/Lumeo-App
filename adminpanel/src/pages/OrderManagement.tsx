import React, { useState } from 'react';
import { SearchInput } from '../components/ui/Input';
import { DataTable, Column } from '../components/ui/DataTable';
import { StatusBadge, StatusType } from '../components/ui/StatusBadge';
import { Modal } from '../components/ui/Modal';
import { Card } from '../components/ui/Card';
import { CheckCircle, Clock, Truck, Package } from 'lucide-react';
import { cn } from '../lib/utils';
interface Order {
  id: string;
  customer: string;
  seller: string;
  amount: string;
  date: string;
  status: 'Pending' | 'Shipped' | 'Delivered' | 'Cancelled';
}
const mockOrders: Order[] = Array.from({
  length: 20
}).map((_, i) => ({
  id: `#ORD-${1000 + i}`,
  customer: `Customer ${i + 1}`,
  seller: `Shop ${i % 5 + 1}`,
  amount: `$${(Math.random() * 1000 + 50).toFixed(2)}`,
  date: '2023-10-25',
  status: ['Pending', 'Shipped', 'Delivered', 'Cancelled'][i % 4] as any
}));
export function OrderManagement() {
  const [activeTab, setActiveTab] = useState('All');
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const tabs = ['All', 'Pending', 'Shipped', 'Delivered', 'Cancelled'];
  const columns: Column<Order>[] = [
  {
    header: 'Order ID',
    accessorKey: 'id',
    className: 'font-mono text-brand-accent font-medium'
  },
  {
    header: 'Customer',
    accessorKey: 'customer'
  },
  {
    header: 'Seller',
    accessorKey: 'seller'
  },
  {
    header: 'Amount',
    accessorKey: 'amount'
  },
  {
    header: 'Date',
    accessorKey: 'date'
  },
  {
    header: 'Status',
    cell: (order) =>
    <StatusBadge status={order.status.toLowerCase() as StatusType} />

  }];

  const filteredData =
  activeTab === 'All' ?
  mockOrders :
  mockOrders.filter((o) => o.status === activeTab);
  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between gap-4 items-center">
        <h1 className="text-2xl font-bold text-white">Order Management</h1>
        <div className="w-full sm:w-72">
          <SearchInput />
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b border-dark-border overflow-x-auto pb-1">
        {tabs.map((tab) =>
        <button
          key={tab}
          onClick={() => setActiveTab(tab)}
          className={cn(
            'px-4 py-2 text-sm font-medium rounded-t-lg transition-colors whitespace-nowrap relative',
            activeTab === tab ?
            'text-brand-accent bg-brand-accent/5' :
            'text-gray-400 hover:text-white hover:bg-dark-surface'
          )}>

            {tab}
            {activeTab === tab &&
          <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-brand-accent" />
          }
          </button>
        )}
      </div>

      <DataTable
        columns={columns}
        data={filteredData}
        onRowClick={(order) => setSelectedOrder(order)} />


      <Modal
        isOpen={!!selectedOrder}
        onClose={() => setSelectedOrder(null)}
        title={`Order Details ${selectedOrder?.id}`}
        size="lg">

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Left Column */}
          <div className="space-y-6">
            <Card className="bg-dark-bg">
              <h4 className="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-4">
                Shipping Address
              </h4>
              <p className="text-white">John Doe</p>
              <p className="text-gray-400 text-sm mt-1">
                123 Main Street, Apt 4B
                <br />
                Colombo 03, Western Province
                <br />
                Sri Lanka
              </p>
            </Card>

            <div>
              <h4 className="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-4">
                Items
              </h4>
              <div className="space-y-3">
                {[1, 2].map((i) =>
                <div
                  key={i}
                  className="flex gap-3 items-center p-3 bg-dark-bg rounded-lg border border-dark-border">

                    <div className="w-12 h-12 bg-gray-700 rounded-md" />
                    <div className="flex-1">
                      <p className="text-sm font-medium text-white">
                        Modern Chair
                      </p>
                      <p className="text-xs text-gray-500">Qty: 1</p>
                    </div>
                    <p className="text-sm font-medium text-white">$150.00</p>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Right Column - Timeline */}
          <div className="bg-dark-bg rounded-xl p-6 border border-dark-border">
            <h4 className="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-6">
              Order Timeline
            </h4>
            <div className="relative space-y-8 pl-2">
              {/* Vertical Line */}
              <div className="absolute left-[15px] top-2 bottom-2 w-0.5 bg-dark-border" />

              {[
              {
                status: 'Order Placed',
                date: 'Oct 25, 10:30 AM',
                icon: Package,
                active: true,
                completed: true
              },
              {
                status: 'Payment Confirmed',
                date: 'Oct 25, 10:35 AM',
                icon: CheckCircle,
                active: true,
                completed: true
              },
              {
                status: 'Shipped',
                date: 'Oct 26, 09:00 AM',
                icon: Truck,
                active: true,
                completed: false
              },
              {
                status: 'Delivered',
                date: 'Estimated Oct 28',
                icon: CheckCircle,
                active: false,
                completed: false
              }].
              map((step, i) =>
              <div key={i} className="relative flex items-start gap-4">
                  <div
                  className={cn(
                    'relative z-10 w-8 h-8 rounded-full flex items-center justify-center border-2',
                    step.completed ?
                    'bg-status-success border-status-success text-black' :
                    step.active ?
                    'bg-dark-bg border-brand-accent text-brand-accent animate-pulse' :
                    'bg-dark-bg border-dark-border text-gray-600'
                  )}>

                    <step.icon className="h-4 w-4" />
                  </div>
                  <div>
                    <p
                    className={cn(
                      'text-sm font-medium',
                      step.active || step.completed ?
                      'text-white' :
                      'text-gray-500'
                    )}>

                      {step.status}
                    </p>
                    <p className="text-xs text-gray-500 mt-0.5">{step.date}</p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </Modal>
    </div>);

}