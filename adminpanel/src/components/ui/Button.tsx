import React from 'react';
import { Loader2 } from 'lucide-react';
import { cn } from '../../lib/utils';
import { motion } from 'framer-motion';
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'destructive' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  icon?: React.ReactNode;
}
export function Button({
  className,
  variant = 'primary',
  size = 'md',
  loading = false,
  icon,
  children,
  disabled,
  ...props
}: ButtonProps) {
  const variants = {
    primary:
    'bg-brand-accent text-brand-primary hover:bg-opacity-90 font-semibold',
    secondary:
    'border border-dark-border text-gray-300 hover:bg-dark-hover hover:text-white',
    destructive:
    'bg-status-danger/10 text-status-danger hover:bg-status-danger/20 border border-status-danger/20',
    ghost: 'text-gray-400 hover:text-white hover:bg-dark-hover'
  };
  const sizes = {
    sm: 'h-8 px-3 text-xs',
    md: 'h-10 px-4 text-sm',
    lg: 'h-12 px-6 text-base'
  };
  return (
    <motion.button
      whileTap={{
        scale: 0.98
      }}
      className={cn(
        'inline-flex items-center justify-center rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-brand-accent/50 disabled:opacity-50 disabled:pointer-events-none',
        variants[variant],
        sizes[size],
        className
      )}
      disabled={disabled || loading}
      {...props}>

      {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
      {!loading && icon && <span className="mr-2">{icon}</span>}
      {children}
    </motion.button>);

}