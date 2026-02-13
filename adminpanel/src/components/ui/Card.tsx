import React from 'react';
import { cn } from '../../lib/utils';
import { motion } from 'framer-motion';
interface CardProps {
  children: React.ReactNode;
  className?: string;
  padding?: 'none' | 'sm' | 'md' | 'lg';
  hover?: boolean;
  onClick?: () => void;
}
export function Card({
  children,
  className,
  padding = 'md',
  hover = false,
  onClick
}: CardProps) {
  const paddings = {
    none: '',
    sm: 'p-4',
    md: 'p-6',
    lg: 'p-8'
  };
  const Wrapper = hover || onClick ? motion.div : 'div';
  return (
    // @ts-ignore - Framer motion types can be tricky with dynamic components, but this is valid
    <Wrapper
      className={cn(
        'bg-dark-surface border border-dark-border rounded-xl shadow-sm overflow-hidden',
        paddings[padding],
        (hover || onClick) &&
        'cursor-pointer hover:border-brand-accent/30 transition-colors',
        className
      )}
      onClick={onClick}
      {...hover || onClick ?
      {
        whileHover: {
          y: -2
        },
        transition: {
          duration: 0.2
        }
      } :
      {}}>

      {children}
    </Wrapper>);

}