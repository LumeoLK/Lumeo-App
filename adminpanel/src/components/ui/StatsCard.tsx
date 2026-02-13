import React from 'react';
import { Card } from './Card';
import { ArrowUpRight, ArrowDownRight, BoxIcon } from 'lucide-react';
import { cn } from '../../lib/utils';
import { motion } from 'framer-motion';
interface StatsCardProps {
  title: string;
  value: string;
  change?: string;
  changeType?: 'up' | 'down';
  icon: BoxIcon;
  delay?: number;
}
export function StatsCard({
  title,
  value,
  change,
  changeType,
  icon: Icon,
  delay = 0
}: StatsCardProps) {
  return (
    <motion.div
      initial={{
        opacity: 0,
        y: 20
      }}
      animate={{
        opacity: 1,
        y: 0
      }}
      transition={{
        duration: 0.4,
        delay
      }}>

      <Card className="relative overflow-hidden">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-sm font-medium text-gray-400 mb-1">{title}</p>
            <h3 className="text-2xl font-bold text-white">{value}</h3>
          </div>
          <div className="p-2 bg-brand-accent/10 rounded-lg">
            <Icon className="h-5 w-5 text-brand-accent" />
          </div>
        </div>

        {change &&
        <div className="mt-4 flex items-center text-sm">
            <span
            className={cn(
              'flex items-center font-medium',
              changeType === 'up' ?
              'text-status-success' :
              'text-status-danger'
            )}>

              {changeType === 'up' ?
            <ArrowUpRight className="h-4 w-4 mr-1" /> :

            <ArrowDownRight className="h-4 w-4 mr-1" />
            }
              {change}
            </span>
            <span className="text-gray-500 ml-2">vs last month</span>
          </div>
        }
      </Card>
    </motion.div>);

}