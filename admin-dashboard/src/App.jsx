import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';

// Layout
import DashboardLayout from './components/layout/DashboardLayout.jsx';

// Pages
import Dashboard from './pages/Dashboard.jsx';
import OrderManagement from './pages/OrderManagement.jsx';
import ProductManagement from './pages/ProductManagement.jsx';
import ProductDetail from './pages/ProductDetail.jsx';
import SellerVerification from './pages/SellerVerification.jsx';
import UserManagement from './pages/UserManagement.jsx';
import CustomRequests from './pages/CustomRequests.jsx';
import Settings from './pages/Settings.jsx';

function App() {
  return (
    <Router>
      <Routes>
        <Route element={<DashboardLayout />}>
          <Route path="/" element={<Dashboard />} />
          <Route path="/orders" element={<OrderManagement />} />
          <Route path="/products" element={<ProductManagement />} />
          <Route path="/products/:id" element={<ProductDetail />} />
          <Route path="/sellers" element={<SellerVerification />} />
          <Route path="/users" element={<UserManagement />} />
          <Route path="/requests" element={<CustomRequests />} />
          <Route path="/settings" element={<Settings />} />
        </Route>

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}

export default App;