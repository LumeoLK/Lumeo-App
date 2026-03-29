import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';

// Layout
import DashboardLayout from './components/layout/DashboardLayout.jsx';

// Pages
import Dashboard from './pages/Dashboard.jsx';
import OrderManagement from './pages/OrderManagement.jsx';
import ProductManagement from './pages/ProductManagement.jsx';
import ProductDetail from './pages/ProductDetail.jsx';
import SellerVerification from './pages/SellerVerification.jsx';
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
          <Route path="/settings" element={<Settings />} />
        </Route>

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
      
      <Toaster 
        position="top-right"
        toastOptions={{
          duration: 4000,
          style: {
            background: '#18181b',
            color: '#fff',
            border: '1px solid #27272a',
          },
          success: {
            iconTheme: {
              primary: '#10b981',
              secondary: '#fff',
            },
          },
          error: {
            iconTheme: {
              primary: '#ef4444',
              secondary: '#fff',
            },
          },
        }}
      />
    </Router>
  );
}

export default App;