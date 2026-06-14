# Aegis Nexus

Premium AI orchestration platform — **Version 1** delivers project foundation, UI, database schema, and backend module structure. AI provider routing is intentionally deferred.

## Stack

| Layer    | Technology        |
|----------|-------------------|
| Frontend | Flutter (Web, Mobile, Desktop) |
| Backend  | Node.js + Express |
| Database | PostgreSQL        |

## Repository layout

```
aegis_nexus/
├── lib/                    # Flutter — Clean Architecture
│   ├── app/                # App entry, routing
│   ├── core/               # Theme, constants, shared widgets
│   └── features/           # auth, conversations, home, profile, settings, shell
├── backend/                # Express API
│   ├── database/schema.sql
│   └── src/modules/        # auth, users, chat, ai-router, database
└── test/
```

## Quick start

### Frontend

```bash
flutter pub get
flutter run -d chrome   # or windows / android / ios
```

### Backend

```bash
cd backend
cp .env.example .env
npm install
createdb aegis_nexus    # PostgreSQL CLI
npm run db:migrate
npm run dev
```

API health: `http://localhost:3000/health`

## Flutter architecture

**Feature-first Clean Architecture** (presentation → domain → data per feature):

- **Presentation**: screens, widgets, `ChangeNotifier` providers
- **Domain**: models and contracts (e.g. `UserModel`, `ConversationItem`)
- **Data**: repositories (stubs in V1; HTTP clients in V2)

**Core** holds design system: `AppColors`, `AppTheme`, `GlassContainer`, `AegisLogo`.

**Navigation**: `go_router` with a `ShellRoute` wrapping Home, Settings, and Profile so the conversation sidebar persists across routes.

**Responsive**: sidebar collapses on viewports &lt; 900px; drawer on mobile.

## Backend architecture

Each module uses **routes → controller → service → repository**:

- No business logic in routes
- Services enforce validation and orchestration
- Repositories own SQL via the shared `databaseModule` pool

**AI Router** module exists as a stub (`501` on `/ai/route`) so provider plugins can land without restructuring.

## Database

Tables: `users`, `conversations`, `messages` (see `backend/database/schema.sql`).

- UUID primary keys, `message_role` enum
- Cascading deletes from user → conversations → messages
- `updated_at` triggers on users and conversations

## V1 scope (included)

- Dark glassmorphism UI with animations
- Main prompt composer (voice/upload/send UI only)
- Conversation history sidebar (in-memory)
- Settings and profile screens
- Auth module structure (register/login/JWT)
- Chat CRUD API (persistence when DB is connected)

## V2 (not in this release)

- Live API integration from Flutter
- AI provider adapters and streaming responses
- Real voice transcription and file ingestion pipeline

## License

Private / UNLICENSED — adjust as needed for your organization.
