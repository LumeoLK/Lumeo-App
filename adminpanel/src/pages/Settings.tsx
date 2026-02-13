import React, { useState } from 'react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Upload, Trash2, Save, LogOut } from 'lucide-react';
import { cn } from '../lib/utils';
export function Settings() {
  const [activeTab, setActiveTab] = useState<'banners' | 'profile'>('banners');
  return (
    <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
      {/* Settings Nav */}
      <Card className="lg:col-span-1 h-fit" padding="sm">
        <nav className="space-y-1">
          <button
            onClick={() => setActiveTab('banners')}
            className={cn(
              'w-full flex items-center px-4 py-2 text-sm font-medium rounded-lg transition-colors',
              activeTab === 'banners' ?
              'bg-brand-accent/10 text-brand-accent' :
              'text-gray-400 hover:text-white hover:bg-dark-hover'
            )}>

            Banners & Featured
          </button>
          <button
            onClick={() => setActiveTab('profile')}
            className={cn(
              'w-full flex items-center px-4 py-2 text-sm font-medium rounded-lg transition-colors',
              activeTab === 'profile' ?
              'bg-brand-accent/10 text-brand-accent' :
              'text-gray-400 hover:text-white hover:bg-dark-hover'
            )}>

            Admin Profile
          </button>
        </nav>
      </Card>

      {/* Content Area */}
      <div className="lg:col-span-3 space-y-6">
        {activeTab === 'banners' ?
        <>
            <Card>
              <h3 className="text-lg font-semibold text-white mb-6">
                Promotional Banners
              </h3>
              <div className="space-y-6">
                {[1, 2, 3].map((i) =>
              <div
                key={i}
                className="border border-dark-border rounded-xl p-4 bg-dark-bg">

                    <div className="aspect-[3/1] bg-dark-surface rounded-lg mb-4 flex items-center justify-center border border-dashed border-dark-border">
                      <div className="text-center">
                        <Upload className="h-8 w-8 text-gray-600 mx-auto mb-2" />
                        <p className="text-sm text-gray-500">Banner Slot {i}</p>
                      </div>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm text-gray-400">
                        Main Home Banner {i}
                      </span>
                      <div className="flex gap-2">
                        <Button variant="secondary" size="sm">
                          Replace
                        </Button>
                        <Button
                      variant="ghost"
                      size="sm"
                      className="text-status-danger"
                      icon={<Trash2 className="h-4 w-4" />} />

                      </div>
                    </div>
                  </div>
              )}
              </div>
            </Card>

            <Card>
              <h3 className="text-lg font-semibold text-white mb-6">
                Featured Products
              </h3>
              <p className="text-gray-400 text-sm">
                Manage products displayed in the "Featured" section on the
                homepage.
              </p>
              {/* Toggle list would go here */}
            </Card>
          </> :

        <Card>
            <h3 className="text-lg font-semibold text-white mb-6">
              Profile Settings
            </h3>

            <div className="flex items-center gap-6 mb-8">
              <div className="h-20 w-20 rounded-full bg-dark-surface border-2 border-brand-accent/50 flex items-center justify-center text-2xl font-bold text-brand-accent">
                AD
              </div>
              <div>
                <Button variant="secondary" size="sm">
                  Change Avatar
                </Button>
              </div>
            </div>

            <form className="space-y-6 max-w-md">
              <Input label="Full Name" defaultValue="Admin User" />
              <Input
              label="Email Address"
              defaultValue="admin@lumeo.lk"
              disabled />


              <div className="pt-4 border-t border-dark-border">
                <h4 className="text-sm font-medium text-white mb-4">
                  Change Password
                </h4>
                <div className="space-y-4">
                  <Input type="password" label="Current Password" />
                  <Input type="password" label="New Password" />
                  <Input type="password" label="Confirm New Password" />
                </div>
              </div>

              <div className="flex items-center justify-between pt-6">
                <Button
                variant="destructive"
                icon={<LogOut className="h-4 w-4" />}>

                  Logout
                </Button>
                <Button icon={<Save className="h-4 w-4" />}>
                  Save Changes
                </Button>
              </div>
            </form>
          </Card>
        }
      </div>
    </div>);

}