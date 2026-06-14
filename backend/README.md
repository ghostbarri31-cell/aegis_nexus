# Aegis Nexus API

Node.js + Express backend for the Aegis Nexus AI orchestration platform (V1 foundation).

## Architecture

```
src/
├── server.js          # Entry point
├── app.js             # Express factory
├── config/            # Environment configuration
├── middleware/        # Auth, errors
├── routes/            # API aggregator
└── modules/           # Feature modules (Clean Architecture layers)
    ├── database/      # Connection pool
    ├── auth/          # Register, login, JWT
    ├── users/         # Profile CRUD
    ├── chat/          # Conversations & messages
    └── ai-router/     # Provider routing (V1 stub)
```

Each module follows **routes → controller → service → repository**:

- **Routes**: HTTP mapping only
- **Controller**: Request/response adaptation
- **Service**: Business rules
- **Repository**: SQL / data access

## Setup

```bash
cd backend
cp .env.example .env
npm install
```

Create the database and apply schema:

```bash
createdb aegis_nexus
npm run db:migrate
```

Start the server:

```bash
npm run dev
```

Health check: `GET http://localhost:3000/health`

API base: `http://localhost:3000/api/v1`

## API Endpoints (V1)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/register` | Create account |
| POST | `/auth/login` | Obtain JWT |
| GET | `/auth/me` | Current user (auth) |
| GET | `/users/me` | Profile (auth) |
| PATCH | `/users/me` | Update profile (auth) |
| GET | `/chat/conversations` | List conversations (auth) |
| POST | `/chat/conversations` | New conversation (auth) |
| GET | `/chat/conversations/:id/messages` | Messages (auth) |
| POST | `/chat/conversations/:id/messages` | Store message (auth) |
| GET | `/ai/providers` | Provider stubs (auth) |
| POST | `/ai/route` | Routing stub — 501 (auth) |
