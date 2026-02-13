import React from 'react';
import { cn } from '../../lib/utils';
export type StatusType =
'success' |
'warning' |
'danger' |
'info' |
'pending' |
'processing' |
'live' |
'failed' |
'approved' |
'rejected' |
'active' |
'banned' |
'shipped' |
'delivered' |
'cancelled';
interface StatusBadgeProps {
  status: StatusType;
  className?: string;
}
export function StatusBadge({ status, className }: StatusBadgeProps) {
  const styles: Record<string, string> = {
    // Green / Success
    success:
    'bg-status-success/10 text-status-success border-status-success/20',
    live: 'bg-status-success/10 text-status-success border-status-success/20',
    approved:
    'bg-status-success/10 text-status-success border-status-success/20',
    active: 'bg-status-success/10 text-status-success border-status-success/20',
    delivered:
    'bg-status-success/10 text-status-success border-status-success/20',
    // Amber / Warning
    warning:
    'bg-status-warning/10 text-status-warning border-status-warning/20',
    pending:
    'bg-status-warning/10 text-status-warning border-status-warning/20',
    // Red / Danger
    danger: 'bg-status-danger/10 text-status-danger border-status-danger/20',
    failed: 'bg-status-danger/10 text-status-danger border-status-danger/20',
    rejected: 'bg-status-danger/10 text-status-danger border-status-danger/20',
    banned: 'bg-status-danger/10 text-status-danger border-status-danger/20',
    cancelled: 'bg-status-danger/10 text-status-danger border-status-danger/20',
    // Blue / Info
    info: 'bg-blue-500/10 text-blue-400 border-blue-500/20',
    processing: 'bg-blue-500/10 text-blue-400 border-blue-500/20',
    shipped: 'bg-blue-500/10 text-blue-400 border-blue-500/20'
  };
  // Fallback for unknown statuses
  const style =
  styles[status.toLowerCase()] ||
  'bg-gray-500/10 text-gray-400 border-gray-500/20';
  return (
    <span
      className={cn(
        'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border',
        style,
        className
      )}>

      <span className="w-1.5 h-1.5 rounded-full bg-current mr-1.5 opacity-70" />
      {status.charAt(0).toUpperCase() + status.slice(1)}
    </span>);

}