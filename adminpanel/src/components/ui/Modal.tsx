import React, { useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X } from 'lucide-react';
import { createPortal } from 'react-dom';
import { cn } from '../../lib/utils';
interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  footer?: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl';
}
export function Modal({
  isOpen,
  onClose,
  title,
  children,
  footer,
  size = 'md'
}: ModalProps) {
  const sizes = {
    sm: 'max-w-md',
    md: 'max-w-lg',
    lg: 'max-w-2xl',
    xl: 'max-w-4xl'
  };
  // Prevent scrolling when modal is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [isOpen]);
  return createPortal(
    <AnimatePresence>
      {isOpen &&
      <>
          {/* Backdrop */}
          <motion.div
          initial={{
            opacity: 0
          }}
          animate={{
            opacity: 1
          }}
          exit={{
            opacity: 0
          }}
          onClick={onClose}
          className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">

            {/* Modal Content */}
            <motion.div
            initial={{
              scale: 0.95,
              opacity: 0,
              y: 20
            }}
            animate={{
              scale: 1,
              opacity: 1,
              y: 0
            }}
            exit={{
              scale: 0.95,
              opacity: 0,
              y: 20
            }}
            onClick={(e) => e.stopPropagation()}
            className={cn(
              'w-full bg-dark-surface border border-dark-border rounded-xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]',
              sizes[size]
            )}>

              {/* Header */}
              <div className="flex items-center justify-between px-6 py-4 border-b border-dark-border">
                <h3 className="text-lg font-semibold text-white">{title}</h3>
                <button
                onClick={onClose}
                className="text-gray-400 hover:text-white transition-colors p-1 rounded-md hover:bg-dark-hover">

                  <X className="h-5 w-5" />
                </button>
              </div>

              {/* Body */}
              <div className="p-6 overflow-y-auto custom-scrollbar">
                {children}
              </div>

              {/* Footer */}
              {footer &&
            <div className="px-6 py-4 bg-dark-bg/50 border-t border-dark-border flex justify-end gap-3">
                  {footer}
                </div>
            }
            </motion.div>
          </motion.div>
        </>
      }
    </AnimatePresence>,
    document.body
  );
}