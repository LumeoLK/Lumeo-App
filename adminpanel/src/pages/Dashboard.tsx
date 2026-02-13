import React from 'react';
import {
  DollarSign,
  Users,
  Store,
  ShieldCheck,
  TrendingUp,
  Clock,
  ShoppingBag } from
'lucide-react';
import { StatsCard } from '../components/ui/StatsCard';
import { Card } from '../components/ui/Card';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Area,
  AreaChart } from
'recharts';
import { motion } from 'framer-motion';
const chartData = [
{
  name: 'Mon',
  value: 4000
},
{
  name: 'Tue',
  value: 3000
},
{
  name: 'Wed',
  value: 2000
},
{
  name: 'Thu',
  value: 2780
},
{
  name: 'Fri',
  value: 1890
},
{
  name: 'Sat',
  value: 2390
},
{
  name: 'Sun',
  value: 3490
}];

const activityData = [
{
  id: 1,
  type: 'user',
  text: 'New user registration: Sarah M.',
  time: '2 mins ago',
  icon: Users,
  color: 'text-blue-400 bg-blue-400/10'
},
{
  id: 2,
  type: 'order',
  text: 'New order #1234 from John D.',
  time: '15 mins ago',
  icon: ShoppingBag,
  color: 'text-green-400 bg-green-400/10'
},
{
  id: 3,
  type: 'seller',
  text: 'Seller verification request: Modern Living',
  time: '1 hour ago',
  icon: ShieldCheck,
  color: 'text-brand-accent bg-brand-accent/10'
},
{
  id: 4,
  type: 'product',
  text: 'New product added: Velvet Sofa',
  time: '3 hours ago',
  icon: Store,
  color: 'text-purple-400 bg-purple-400/10'
},
{
  id: 5,
  type: 'user',
  text: 'New user registration: Mike R.',
  time: '5 hours ago',
  icon: Users,
  color: 'text-blue-400 bg-blue-400/10'
}];

export function Dashboard() {
  return (
    <div className="space-y-6">
      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatsCard
          title="Total Revenue"
          value="$284,500"
          change="12.5%"
          changeType="up"
          icon={DollarSign}
          delay={0} />

        <StatsCard
          title="Total Users"
          value="12,847"
          change="8.2%"
          changeType="up"
          icon={Users}
          delay={0.1} />

        <StatsCard
          title="Active Sellers"
          value="342"
          change="5.1%"
          changeType="up"
          icon={Store}
          delay={0.2} />

        <StatsCard
          title="Pending Requests"
          value="18"
          change="3"
          changeType="down"
          icon={ShieldCheck}
          delay={0.3} />

      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Chart Section */}
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
            delay: 0.4
          }}
          className="lg:col-span-2">

          <Card className="h-full min-h-[400px] flex flex-col">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-lg font-semibold text-white">
                Revenue Overview
              </h3>
              <div className="flex bg-dark-bg rounded-lg p-1 border border-dark-border">
                {['Day', 'Week', 'Month'].map((tab, i) =>
                <button
                  key={tab}
                  className={`px-3 py-1 text-xs font-medium rounded-md transition-colors ${i === 1 ? 'bg-brand-accent text-brand-primary' : 'text-gray-400 hover:text-white'}`}>

                    {tab}
                  </button>
                )}
              </div>
            </div>

            <div className="flex-1 w-full h-full min-h-[300px]">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData}>
                  <defs>
                    <linearGradient id="colorValue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#FBB040" stopOpacity={0.3} />
                      <stop offset="95%" stopColor="#FBB040" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid
                    strokeDasharray="3 3"
                    stroke="#2A2728"
                    vertical={false} />

                  <XAxis
                    dataKey="name"
                    stroke="#6B7280"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false} />

                  <YAxis
                    stroke="#6B7280"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                    tickFormatter={(value) => `$${value}`} />

                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#1A1819',
                      borderColor: '#2A2728',
                      color: '#fff'
                    }}
                    itemStyle={{
                      color: '#FBB040'
                    }} />

                  <Area
                    type="monotone"
                    dataKey="value"
                    stroke="#FBB040"
                    strokeWidth={2}
                    fillOpacity={1}
                    fill="url(#colorValue)" />

                </AreaChart>
              </ResponsiveContainer>
            </div>
          </Card>
        </motion.div>

        {/* Recent Activity */}
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
            delay: 0.5
          }}>

          <Card className="h-full flex flex-col">
            <h3 className="text-lg font-semibold text-white mb-6">
              Recent Activity
            </h3>
            <div className="space-y-6 overflow-y-auto pr-2 custom-scrollbar max-h-[350px]">
              {activityData.map((item, i) =>
              <div key={item.id} className="flex gap-4">
                  <div
                  className={`flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center ${item.color}`}>

                    <item.icon className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-200">{item.text}</p>
                    <p className="text-xs text-gray-500 mt-1 flex items-center">
                      <Clock className="h-3 w-3 mr-1" />
                      {item.time}
                    </p>
                  </div>
                </div>
              )}
            </div>
            <button className="mt-auto w-full py-2 text-sm text-brand-accent hover:text-brand-accent/80 transition-colors border-t border-dark-border pt-4">
              View All Activity
            </button>
          </Card>
        </motion.div>
      </div>
    </div>);

}