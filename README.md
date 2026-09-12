# VehicleHamApp — Vehicle Service & Roadside Assistance Platform

A full-stack marketplace connecting vehicle owners with service partners: request a service, get matched with a partner, track the job, and pay — with guarantees, reporting, and admin oversight. Backend in Node.js/Express/Prisma, mobile frontend in Flutter.

## Tech Stack
**Backend:** Node.js, Express 5, Prisma ORM (MySQL), JWT auth, bcryptjs, Stripe, Twilio, Nodemailer, Socket.IO, Helmet, express-rate-limit, Zod validation, Winston logging
**Frontend:** Flutter (Android/iOS), with its own API client, session manager, router and theming layer

## Domain Model
`User`, `Partner`, `Admin`, `ServiceType`, `Location` / `UserLocation`, `Request`, `Report`, `CarVerification`, `Guarantee`, `PartnerApplication`, `Transaction`, `Notification`.

## Features
- User & partner authentication, with an admin role for oversight
- Users submit service **Requests**; **Partners** apply and are matched by location/service type
- Car verification step before service
- **Guarantee** (warranty) tracking on completed jobs
- **Transactions** (Stripe) and payment records
- Notifications (email via Nodemailer, SMS via Twilio, push via Socket.IO)
- Partner application review flow, with admin notes
- Reporting (`Report` model) for issue tracking
- Backend test suite covering auth, admin, partner, request, service, transaction, guarantee, location, notification and user flows

## Project Structure
```
backend/
├── controllers/    # Admin, Auth, Guarantee, Location, Notification, Partner, Report, Request, Service, Transaction, User
├── routes/
├── prisma/          # schema.prisma + migrations
├── test/            # per-domain test suites
└── validators/
frontend/            # Flutter app (lib/core/{api,auth,router,services,theme})
```

## Getting Started

**Backend:**
```bash
cd backend
npm install
cp .env.example .env
# DATABASE_URL="mysql://USER:PASSWORD@HOST:PORT/DATABASE"
# JWT_SECRET="..."
npx prisma migrate dev --name init
npx prisma generate
npm start          # runs on port 8081
```

**Frontend (Flutter):**
```bash
cd frontend
flutter pub get
flutter run
```

See `howBackendWork.md` and `apiList.txt` in the repo for backend architecture notes and the full API endpoint list.
