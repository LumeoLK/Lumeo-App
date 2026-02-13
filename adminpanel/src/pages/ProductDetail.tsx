import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Store } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { StatusBadge } from '../components/ui/StatusBadge';
export function ProductDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  return (
    <div className="space-y-6">
      <button
        onClick={() => navigate('/products')}
        className="flex items-center text-gray-400 hover:text-white transition-colors">

        <ArrowLeft className="h-4 w-4 mr-2" />
        Back to Products
      </button>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Product Info */}
        <div className="space-y-6">
          <Card className="space-y-6">
            <div className="aspect-video w-full bg-gray-800 rounded-lg overflow-hidden relative">
              <img
                src="https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80"
                alt="Product"
                className="w-full h-full object-cover" />

              <div className="absolute top-4 right-4">
                <StatusBadge status="live" />
              </div>
            </div>

            <div>
              <div className="flex justify-between items-start mb-2">
                <h1 className="text-2xl font-bold text-white">
                  Modern Velvet Sofa
                </h1>
                <span className="text-2xl font-bold text-brand-accent">
                  $899.00
                </span>
              </div>
              <div className="flex items-center gap-4 text-sm text-gray-400 mb-4">
                <span className="px-2 py-1 bg-dark-bg rounded border border-dark-border">
                  Living Room
                </span>
                <span>Stock: 12 units</span>
                <span>SKU: SOFA-001-GRY</span>
              </div>
              <p className="text-gray-300 leading-relaxed">
                Elegant modern sofa upholstered in high-quality velvet. Features
                a sturdy wooden frame and comfortable foam cushioning. Perfect
                for contemporary living spaces.
              </p>
            </div>

            <div className="pt-6 border-t border-dark-border">
              <div className="flex items-center gap-3 p-3 bg-dark-bg rounded-lg border border-dark-border">
                <div className="p-2 bg-brand-accent/10 rounded-full">
                  <Store className="h-5 w-5 text-brand-accent" />
                </div>
                <div>
                  <p className="text-sm font-medium text-white">
                    Colombo Woodworks
                  </p>
                  <p className="text-xs text-gray-500">Verified Seller</p>
                </div>
              </div>
            </div>
          </Card>

          <div className="grid grid-cols-2 gap-4">
            {[
            {
              label: 'Weight',
              value: '45 kg'
            },
            {
              label: 'Dimensions',
              value: '200 x 90 x 85 cm'
            },
            {
              label: 'Material',
              value: 'Velvet, Wood, Foam'
            },
            {
              label: 'Color',
              value: 'Grey'
            }].
            map((item, i) =>
            <Card key={i} padding="sm" className="bg-dark-bg">
                <p className="text-xs text-gray-500 mb-1">{item.label}</p>
                <p className="text-white font-medium">{item.value}</p>
              </Card>
            )}
          </div>
        </div>

        {/* 3D Preview */}
        <div className="flex flex-col h-full">
          <Card className="flex-1 flex flex-col min-h-[500px] relative bg-gradient-to-b from-dark-surface to-dark-bg border-brand-accent/20">
            <div className="absolute top-4 left-4 z-10">
              <h3 className="text-lg font-semibold text-white flex items-center gap-2">
                <div className="h-5 w-5 text-brand-accent" />
                AR Model Preview
              </h3>
            </div>

            <div className="flex-1 flex flex-col items-center justify-center text-center p-8">
              <div className="w-32 h-32 rounded-full bg-brand-accent/5 border border-brand-accent/20 flex items-center justify-center mb-6 animate-pulse">
                <div className="h-12 w-12 text-brand-accent" />
              </div>
              <h4 className="text-xl font-medium text-white mb-2">
                Interactive 3D Model
              </h4>
              <p className="text-gray-400 max-w-xs mx-auto mb-8">
                This is a placeholder for the .glb model viewer. Users can
                rotate, zoom, and interact with the furniture piece here.
              </p>
              <div className="flex gap-3">
                <Button variant="secondary" icon={<div className="h-4 w-4" />}>
                  Regenerate Model
                </Button>
              </div>
            </div>

            <div className="absolute bottom-4 left-0 right-0 text-center text-xs text-gray-600">
              Use mouse to rotate • Scroll to zoom
            </div>
          </Card>
        </div>
      </div>
    </div>);

}