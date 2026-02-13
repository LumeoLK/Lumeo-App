import React, { useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { cn } from '../../lib/utils';
import { motion } from 'framer-motion';
export interface Column<T> {
  header: string;
  accessorKey?: keyof T;
  cell?: (item: T) => React.ReactNode;
  className?: string;
}
interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  onRowClick?: (item: T) => void;
  pageSize?: number;
}
export function DataTable<
  T extends {
    id: string | number;
  }>(
{ columns, data, onRowClick, pageSize = 10 }: DataTableProps<T>) {
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(pageSize);
  const totalPages = Math.ceil(data.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const currentData = data.slice(startIndex, endIndex);
  return (
    <div className="w-full bg-dark-surface border border-dark-border rounded-xl overflow-hidden flex flex-col">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-dark-bg border-b border-dark-border">
              {columns.map((col, idx) =>
              <th
                key={idx}
                className={cn(
                  'px-6 py-4 text-xs font-semibold text-gray-400 uppercase tracking-wider',
                  col.className
                )}>

                  {col.header}
                </th>
              )}
            </tr>
          </thead>
          <tbody className="divide-y divide-dark-border">
            {currentData.length > 0 ?
            currentData.map((item, idx) =>
            <motion.tr
              key={item.id}
              initial={{
                opacity: 0,
                y: 10
              }}
              animate={{
                opacity: 1,
                y: 0
              }}
              transition={{
                delay: idx * 0.03
              }}
              onClick={() => onRowClick?.(item)}
              className={cn(
                'bg-dark-surface transition-colors',
                onRowClick ? 'cursor-pointer hover:bg-dark-hover' : ''
              )}>

                  {columns.map((col, colIdx) =>
              <td
                key={colIdx}
                className={cn(
                  'px-6 py-4 text-sm text-gray-300 whitespace-nowrap',
                  col.className
                )}>

                      {col.cell ?
                col.cell(item) :
                item[col.accessorKey as keyof T] as React.ReactNode}
                    </td>
              )}
                </motion.tr>
            ) :

            <tr>
                <td
                colSpan={columns.length}
                className="px-6 py-12 text-center text-gray-500">

                  No data available
                </td>
              </tr>
            }
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="px-6 py-4 border-t border-dark-border bg-dark-surface flex items-center justify-between">
        <div className="text-sm text-gray-500">
          Showing{' '}
          <span className="font-medium text-white">
            {Math.min(startIndex + 1, data.length)}
          </span>{' '}
          to{' '}
          <span className="font-medium text-white">
            {Math.min(endIndex, data.length)}
          </span>{' '}
          of <span className="font-medium text-white">{data.length}</span>{' '}
          results
        </div>

        <div className="flex items-center gap-4">
          <select
            value={itemsPerPage}
            onChange={(e) => {
              setItemsPerPage(Number(e.target.value));
              setCurrentPage(1);
            }}
            className="bg-dark-bg border border-dark-border text-gray-300 text-sm rounded-md px-2 py-1 focus:outline-none focus:border-brand-accent">

            <option value={10}>10 per page</option>
            <option value={20}>20 per page</option>
            <option value={50}>50 per page</option>
          </select>

          <div className="flex gap-2">
            <button
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
              disabled={currentPage === 1}
              className="p-1 rounded-md border border-dark-border text-gray-400 hover:text-white hover:bg-dark-hover disabled:opacity-50 disabled:cursor-not-allowed">

              <ChevronLeft className="h-5 w-5" />
            </button>
            <button
              onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
              disabled={currentPage === totalPages}
              className="p-1 rounded-md border border-dark-border text-gray-400 hover:text-white hover:bg-dark-hover disabled:opacity-50 disabled:cursor-not-allowed">

              <ChevronRight className="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>
    </div>);

}