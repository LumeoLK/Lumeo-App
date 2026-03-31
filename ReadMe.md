# Lumeo Visit us on https://www.lumeo.ltd

Lumeo is a furniture shopping platform built around customization and AR visualization. You can browse and buy furniture, request custom pieces, chat with sellers, and see how things look in your space before buying. Sellers get their own dashboard, and the admin side handles everything from user management to order fulfillment.

**Backend:** https://lumeo-app.onrender.com

---

## What's in here

```
Lumeo-App/
├── admin-dashboard/    React dashboard (JS)
├── adminpanel/         Enhanced admin panel (TS)
├── backend/            Node.js/Express API
├── demo/               Flutter mobile app
├── ml/                 Python ML service (FastAPI)
├── src/                Blueprint-to-3D pipeline
├── Lumeo-worker/       Background job processor
└── assets/             Blueprints and shared assets
```

The backend is the hub. The Flutter app and web dashboards talk to it over HTTP and WebSockets. Heavy work (3D conversion, notifications) gets handed off to the background worker. The ML service runs separately and handles image analysis and blueprint parsing.

---

## Stack

| | |
|---|---|
| Mobile | Flutter, Dart, Riverpod, Dio |
| Web dashboards | React 19, TypeScript, Tailwind, Framer Motion |
| Backend | Node.js, Express, MongoDB, Redis |
| Real-time | Socket.IO, BullMQ |
| ML | FastAPI, PyTorch, CLIP, Rembg |
| 3D | Trimesh, NumPy, OpenCV, Shapely |
| Storage | Cloudinary |
| Auth | JWT, Google Sign-In |

---

## Getting started

You'll need Node 18+, Flutter 3.9.2+, Python 3.8+, MongoDB, and Redis running locally. Cloudinary credentials go in the backend `.env`.

**Backend**
```bash
cd backend && npm install && npm run dev
```

**Admin dashboard**
```bash
cd admin-dashboard && npm install && npm run dev
```

**Admin panel**
```bash
cd adminpanel && npm install && npm run dev
```

**Flutter app**
```bash
cd demo && flutter pub get && flutter run
```

**ML service**
```bash
cd ml && pip install -r requirements.txt && python main.py
```

**Blueprint-to-3D**
```bash
cd src && pip install -r requirements.txt && python main.py
```

**Background worker**
```bash
cd Lumeo-worker && npm install && npm run dev
```

---

## Features

**Mobile app** — auth, product search and browsing, AR visualization, cart and wishlist, order tracking, real-time chat with sellers, custom furniture requests, blueprint-to-3D conversion, seller dashboard, Google Sign-In.

**Backend API** — REST + WebSocket architecture, JWT auth, e-commerce operations, Socket.IO messaging, Cloudinary uploads, order and seller management, reviews, custom request handling, BullMQ job queue.

**Admin dashboards** — user and product management, order monitoring, sales analytics (Recharts), seller verification, system config.

**ML service** — image feature extraction, blueprint parsing, background removal (Rembg), CLIP-based descriptions.

**3D pipeline** — converts blueprint images to OBJ files via mesh generation.

---

## API

```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/password-reset

GET    /api/products
GET    /api/products/:id
POST   /api/products           (admin)

GET    /api/cart
POST   /api/cart
DELETE /api/cart/:itemId

GET    /api/orders
POST   /api/orders
GET    /api/orders/:id

GET    /api/wishlist
POST   /api/wishlist
DELETE /api/wishlist/:productId

GET    /api/chat/conversations
POST   /api/chat/messages
WS     /socket.io

POST   /api/customreq
GET    /api/customreq

POST   /api/seller/register
GET    /api/seller/dashboard
GET    /api/seller/listings

POST   /api/blueprint-to-3d
```

---

## Building for production

```bash
# Web dashboards
npm run build

# Flutter
flutter build apk   # Android
flutter build ios   # iOS
flutter build web   # Web

# Backend
npm start
```



## Troubleshooting

- **MongoDB not connecting** — make sure `mongod` is running and the URI in `.env` is right
- **Redis errors** — run `redis-server`
- **Flutter build failures** — try `flutter clean && flutter pub get`, then check `flutter doctor`
- **ML service down** — check that FastAPI and PyTorch installed correctly; watch the logs for model loading errors

---

## Contributing

```bash
git checkout -b feature/your-feature
git commit -m 'description of change'
git push origin feature/your-feature
# open a pull request
```

---

*Last updated March 2026*
