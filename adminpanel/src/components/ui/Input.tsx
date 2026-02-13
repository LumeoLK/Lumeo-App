import React from 'react';
import { cn } from '../../lib/utils';
import { Search } from 'lucide-react';
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  icon?: React.ReactNode;
  label?: string;
  error?: string;
}
export function Input({ className, icon, label, error, ...props }: InputProps) {
  return (
    <div className="w-full">
      {label &&
      <label className="block text-sm font-medium text-gray-400 mb-1.5">
          {label}
        </label>
      }
      <div className="relative">
        {icon &&
        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-500">
            {icon}
          </div>
        }
        <input
          className={cn(
            'w-full bg-dark-surface border border-dark-border rounded-lg py-2.5 text-gray-200 placeholder:text-gray-600 focus:outline-none focus:ring-2 focus:ring-brand-accent/50 focus:border-transparent transition-all',
            icon ? 'pl-10 pr-4' : 'px-4',
            error ? 'border-status-danger focus:ring-status-danger/50' : '',
            className
          )}
          {...props} />

      </div>
      {error && <p className="mt-1 text-xs text-status-danger">{error}</p>}
    </div>);

}
export function SearchInput(props: InputProps) {
  return (
    <Input
      icon={<Search className="h-4 w-4" />}
      placeholder="Search..."
      {...props} />);


}