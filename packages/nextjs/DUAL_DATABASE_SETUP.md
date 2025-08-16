# Dual Database Setup Guide

This project now supports both Supabase and PostgreSQL (Prisma) databases with easy switching.

## Current Setup

- **Active**: Supabase (bypasses network restrictions)
- **Available**: PostgreSQL with Prisma (for future use)

## How to Switch Databases

### 1. Environment Variables

Set `NEXT_PUBLIC_USE_SUPABASE` in your `.env` file:

```env
# Use Supabase (current)
NEXT_PUBLIC_USE_SUPABASE=true

# Use PostgreSQL (when network allows)
NEXT_PUBLIC_USE_SUPABASE=false
```

### 2. Database Configuration

#### For Supabase:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

#### For PostgreSQL:
```env
DATABASE_URL="postgresql://username:password@host:port/database_name?sslmode=require"
```

## Database Operations

All database operations are handled by `src/lib/database.ts`:

```typescript
import { storeSalt, getSalt, currentDatabase } from "@/lib/database";

// Store salt data (works with both databases)
await storeSalt({
  tokenId: "123",
  contractAddress: "0x...",
  salt: "random_salt",
  uidHash: "hash",
  productCode: "PROD001"
});

// Get salt data (works with both databases)
const saltData = await getSalt("123", "0x...");

// Check which database is currently active
console.log("Using:", currentDatabase);
```

## Migration Between Databases

### From Supabase to PostgreSQL:

1. Set up PostgreSQL database
2. Update `.env`:
   ```env
   NEXT_PUBLIC_USE_SUPABASE=false
   DATABASE_URL="your_postgresql_url"
   ```
3. Run Prisma migrations:
   ```bash
   npm run db:generate
   npm run db:push
   ```

### From PostgreSQL to Supabase:

1. Set up Supabase project
2. Update `.env`:
   ```env
   NEXT_PUBLIC_USE_SUPABASE=true
   NEXT_PUBLIC_SUPABASE_URL=your_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key
   ```

## Data Migration

To migrate data between databases:

### Export from Supabase:
```sql
SELECT * FROM your_supabase_table;
```

### Import to PostgreSQL:
```sql
INSERT INTO salts (token_id, contract_address, salt, uid_hash, uid_code)
VALUES (...);
```

## Development Workflow

1. **Local Development**: Use Supabase (bypasses network restrictions)
2. **Testing**: Use PostgreSQL locally with Docker
3. **Production**: Choose based on your infrastructure

## Benefits

- ✅ **Network Flexibility**: Supabase works around port restrictions
- ✅ **Future Ready**: PostgreSQL setup ready when network allows
- ✅ **Easy Switching**: Single environment variable to change databases
- ✅ **Same API**: Database operations work identically with both
- ✅ **Type Safety**: Prisma provides excellent TypeScript support

## Troubleshooting

### Supabase Issues:
- Check URL and API key
- Verify table exists in Supabase dashboard
- Check RLS (Row Level Security) policies

### PostgreSQL Issues:
- Verify DATABASE_URL format
- Check network connectivity (port 5432)
- Ensure database is running

### Switching Issues:
- Restart development server after changing `NEXT_PUBLIC_USE_SUPABASE`
- Clear browser cache
- Check environment variable spelling 