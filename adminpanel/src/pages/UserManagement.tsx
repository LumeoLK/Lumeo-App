import React, { useState } from 'react';
import { SearchInput } from '../components/ui/Input';
import { DataTable, Column } from '../components/ui/DataTable';
import { StatusBadge, StatusType } from '../components/ui/StatusBadge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Eye, Ban, CheckCircle } from 'lucide-react';
interface User {
  id: number;
  name: string;
  email: string;
  role: 'User' | 'Seller';
  status: 'Active' | 'Banned';
  joinDate: string;
  avatar: string;
}
const mockUsers: User[] = Array.from({
  length: 20
}).map((_, i) => ({
  id: i + 1,
  name: i % 3 === 0 ? `User ${i + 1}` : `Seller ${i + 1}`,
  email: `user${i + 1}@example.com`,
  role: i % 3 === 0 ? 'User' : 'Seller',
  status: i % 10 === 0 ? 'Banned' : 'Active',
  joinDate: '2023-10-15',
  avatar: `https://i.pravatar.cc/150?u=${i}`
}));
export function UserManagement() {
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [isBanModalOpen, setIsBanModalOpen] = useState(false);
  const columns: Column<User>[] = [
  {
    header: 'Name',
    cell: (user) =>
    <div className="flex items-center gap-3">
          <img
        src={user.avatar}
        alt={user.name}
        className="w-8 h-8 rounded-full bg-dark-border" />

          <span className="font-medium text-white">{user.name}</span>
        </div>

  },
  {
    header: 'Email',
    accessorKey: 'email'
  },
  {
    header: 'Role',
    cell: (user) =>
    <span
      className={`px-2 py-1 rounded text-xs font-medium ${user.role === 'Seller' ? 'bg-purple-500/10 text-purple-400' : 'bg-gray-500/10 text-gray-400'}`}>

          {user.role}
        </span>

  },
  {
    header: 'Status',
    cell: (user) =>
    <StatusBadge status={user.status.toLowerCase() as StatusType} />

  },
  {
    header: 'Join Date',
    accessorKey: 'joinDate'
  },
  {
    header: 'Actions',
    cell: (user) =>
    <div className="flex gap-2">
          <Button
        variant="ghost"
        size="sm"
        icon={<Eye className="h-4 w-4" />} />

          <Button
        variant="ghost"
        size="sm"
        className="text-status-danger hover:text-status-danger"
        onClick={(e) => {
          e.stopPropagation();
          setSelectedUser(user);
          setIsBanModalOpen(true);
        }}
        icon={
        user.status === 'Banned' ?
        <CheckCircle className="h-4 w-4" /> :

        <Ban className="h-4 w-4" />

        } />

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
            <option>All Roles</option>
            <option>User</option>
            <option>Seller</option>
          </select>
          <select className="bg-dark-surface border border-dark-border rounded-lg px-3 py-2 text-sm text-gray-300 focus:outline-none focus:border-brand-accent">
            <option>All Status</option>
            <option>Active</option>
            <option>Banned</option>
          </select>
        </div>
      </div>

      <DataTable columns={columns} data={mockUsers} />

      <Modal
        isOpen={isBanModalOpen}
        onClose={() => setIsBanModalOpen(false)}
        title={selectedUser?.status === 'Banned' ? 'Unban User' : 'Ban User'}
        footer={
        <>
            <Button
            variant="secondary"
            onClick={() => setIsBanModalOpen(false)}>

              Cancel
            </Button>
            <Button
            variant="destructive"
            onClick={() => setIsBanModalOpen(false)}>

              {selectedUser?.status === 'Banned' ? 'Unban User' : 'Ban User'}
            </Button>
          </>
        }>

        <p className="text-gray-300">
          Are you sure you want to{' '}
          {selectedUser?.status === 'Banned' ? 'unban' : 'ban'}{' '}
          <span className="font-bold text-white">{selectedUser?.name}</span>?
          {selectedUser?.status !== 'Banned' &&
          ' They will no longer be able to access their account.'}
        </p>
      </Modal>
    </div>);

}