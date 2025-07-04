# Backend Server Documentation

## Quick Start

1. Install dependencies: `npm install`
2. Configure `.env` file (copy from `.env.example` if available)
3. Run migrations: `npx prisma migrate dev`
4. Start server: `npm start` (runs on port 8081)

## Project Structure

├── controllers/ # Business logic handlers
├── generated/ # Auto-generated Prisma client
├── middlewares/ # Express middleware
├── prisma/ # DB schema & migrations
│ └── schema.prisma # Main Prisma config
├── routes/ # API endpoint definitions
├── services/ # Core services
│ ├── prisma/ # DB service
│ └── nodemailer/ # Email service
├── utils/ # Utilities
│ └── uploaders/ # Multer configs
└── validators/ # Zod validation schemas

## Key Files

1. `prisma/schema.prisma` - Database schema definition
2. `routes/*.js` - API route definitions
3. `.env` - Environment variables

## Database Setup

1. Edit DATABASE_URL in `.env`:
   `mysql://USER:PASSWORD@HOST:PORT/DATABASE`
2. Create/run migrations:
   ```bash
   npx prisma migrate dev --name init
   npx prisma generate
   ```

- any problem just call me or debug the hell out of it lol
