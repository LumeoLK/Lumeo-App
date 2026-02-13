import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { SearchInput } from '../components/ui/Input';
import { DataTable, Column } from '../components/ui/DataTable';
import { StatusBadge, StatusType } from '../components/ui/StatusBadge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Edit, Trash2, RefreshCw, Eye } from 'lucide-react';
interface Product {
  id: number;
  title: string;
  price: string;
  stock: number;
  category: string;
  status: 'Pending' | 'Processing' | 'Live' | 'Failed';
  image: string;
}
const mockProducts: Product[] = Array.from({
  length: 15
}).map((_, i) => ({
  id: i + 1,
  title:
  [
  'Modern Sofa',
  'Oak Dining Table',
  'Office Chair',
  'Bed Frame',
  'Bookshelf'][
  i % 5] + ` ${i + 1}`,
  price: `$${(Math.random() * 500 + 50).toFixed(2)}`,
  stock: Math.floor(Math.random() * 50),
  category: ['Living Room', 'Dining', 'Office', 'Bedroom', 'Storage'][i % 5],
  status: ['Pending', 'Processing', 'Live', 'Failed'][i % 4] as any,
  image: `https://images.unsplash.com/photo-${['1555041469-a586c61ea9bc', '1592078615290-033ee584e267', '1505693314120-ba89ae518737'][i % 3]}?w=100&h=100&fit=crop`
}));
export function ProductManagement() {
  const navigate = useNavigate();
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const columns: Column<Product>[] = [
  {
    header: 'Product',
    cell: (product) =>
    <div className="flex items-center gap-3">
          <img
        src={product.image}
        alt={product.title}
        className="w-10 h-10 rounded-md object-cover bg-dark-border" />

          <span className="font-medium text-white">{product.title}</span>
        </div>

  },
  {
    header: 'Category',
    accessorKey: 'category'
  },
  {
    header: 'Price',
    accessorKey: 'price',
    className: 'font-mono text-brand-accent'
  },
  {
    header: 'Stock',
    accessorKey: 'stock'
  },
  {
    header: 'AR Status',
    cell: (product) =>
    <StatusBadge status={product.status.toLowerCase() as StatusType} />

  },
  {
    header: 'Actions',
    cell: (product) =>
    <div className="flex gap-2">
          <Button
        variant="ghost"
        size="sm"
        icon={<Eye className="h-4 w-4" />}
        onClick={(e) => {
          e.stopPropagation();
          navigate(`/products/${product.id}`);
        }} />

          <Button
        variant="ghost"
        size="sm"
        icon={<RefreshCw className="h-4 w-4" />}
        onClick={(e) => e.stopPropagation()} />

          <Button
        variant="ghost"
        size="sm"
        className="text-status-danger hover:text-status-danger"
        icon={<Trash2 className="h-4 w-4" />}
        onClick={(e) => {
          e.stopPropagation();
          setDeleteId(product.id);
        }} />

        </div>

  }];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between gap-4">
        <div className="flex gap-4 flex-1">
          <div className="w-full sm:w-72">
            <SearchInput />
          </div>
          <select className="bg-dark-surface border border-dark-border rounded-lg px-3 py-2 text-sm text-gray-300 focus:outline-none focus:border-brand-accent">
            <option>All Categories</option>
            <option>Living Room</option>
            <option>Bedroom</option>
            <option>Office</option>
          </select>
        </div>
        <Button icon={<RefreshCw className="h-4 w-4" />}>Sync Products</Button>
      </div>

      <DataTable
        columns={columns}
        data={mockProducts}
        onRowClick={(product) => navigate(`/products/${product.id}`)} />


      <Modal
        isOpen={!!deleteId}
        onClose={() => setDeleteId(null)}
        title="Delete Product"
        footer={
        <>
            <Button variant="secondary" onClick={() => setDeleteId(null)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={() => setDeleteId(null)}>
              Delete Product
            </Button>
          </>
        }>

        <p className="text-gray-300">
          Are you sure you want to delete this product? This action cannot be
          undone.
        </p>
      </Modal>
    </div>);

}