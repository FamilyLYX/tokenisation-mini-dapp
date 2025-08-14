# Database Alternatives for Network-Restricted Environments

Since your network blocks PostgreSQL port 5432, here are alternative solutions:

## Option 1: Use Supabase (Recommended)
Supabase provides PostgreSQL but through HTTP APIs, bypassing port restrictions:

```bash
# Revert to Supabase temporarily
npm install @supabase/supabase-js
```

Update your `.env`:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Option 2: Use PlanetScale (MySQL)
PlanetScale uses MySQL which often works better with restricted networks:

```bash
npm install @planetscale/database
```

Update `prisma/schema.prisma`:
```prisma
datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}
```

## Option 3: Use Neon with Connection Pooling
Neon offers connection pooling that might work better:

```env
DATABASE_URL="postgresql://user:pass@pooler.neon.tech:5432/dbname?sslmode=require"
```

## Option 4: Use Railway with Custom Port
Railway allows custom ports:

```env
DATABASE_URL="postgresql://user:pass@railway.app:5433/dbname?sslmode=require"
```

## Option 5: Local Development with Docker
For development, use local PostgreSQL:

```bash
# Start local PostgreSQL
docker run --name postgres -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres

# Use local connection
DATABASE_URL="postgresql://postgres:password@localhost:5432/postgres"
```

## Option 6: Use SQLite for Development
For quick development, use SQLite:

```bash
# Update schema
datasource db {
  provider = "sqlite"
  url      = "file:./dev.db"
}
```

## Recommended Approach:

1. **For Development**: Use local PostgreSQL with Docker
2. **For Production**: Use Supabase (bypasses network restrictions)
3. **For Testing**: Use SQLite

## Quick Fix - Use Supabase:

```bash
# Reinstall Supabase
npm install @supabase/supabase-js

# Update storeSalt.ts to use Supabase
# Update initSupabase.ts
# Update .env with Supabase credentials
```

This will get you working immediately while you explore other options. 