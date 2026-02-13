import React from 'react';
import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import { DashboardLayout } from './components/layout/DashboardLayout';
import { Dashboard } from './pages/Dashboard';
import { UserManagement } from './pages/UserManagement';
import { SellerVerification } from './pages/SellerVerification';
import { ProductManagement } from './pages/ProductManagement';
import { ProductDetail } from './pages/ProductDetail';
import { OrderManagement } from './pages/OrderManagement';
import { CustomRequests } from './pages/CustomRequests';
import { Settings } from './pages/Settings';
export function App() {
  return (
    <HashRouter>
      <Routes>
        <Route path="/" element={<DashboardLayout />}>
          <Route index element={<Dashboard />} />
          <Route path="users" element={<UserManagement />} />
          <Route path="sellers/verification" element={<SellerVerification />} />
          <Route path="products" element={<ProductManagement />} />
          <Route path="products/:id" element={<ProductDetail />} />
          <Route path="orders" element={<OrderManagement />} />
          <Route path="custom-requests" element={<CustomRequests />} />
          <Route path="settings" element={<Settings />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      </Routes>
    </HashRouter>);

}