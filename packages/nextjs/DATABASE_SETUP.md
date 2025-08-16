# Database Setup Guide

## Migration from Supabase to PostgreSQL with Prisma

This guide will help you set up PostgreSQL with Prisma to replace Supabase.

### 1. Install Dependencies

```bash
npm install prisma @prisma/client
```

### 2. Set up Environment Variables

Add your PostgreSQL database URL to your `.env` file:

```env
DATABASE_URL="postgresql://username:password@localhost:5432/your_database_name"
```

### 3. Database Options

#### Option A: Local PostgreSQL
1. Install PostgreSQL locally
2. Create a database
3. Use the connection string: `postgresql://username:password@localhost:5432/database_name`

#### Option B: Cloud PostgreSQL (Recommended)
- **Neon**: https://neon.tech (Free tier available)
- **Supabase**: https://supabase.com (PostgreSQL hosting)
- **Railway**: https://railway.app
- **Vercel Postgres**: https://vercel.com/docs/storage/vercel-postgres

### 4. Initialize Database

#### Using Prisma (Recommended)
```bash
# Generate Prisma client
npm run db:generate

# Push schema to database
npm run db:push

# Or create and run migrations
npm run db:migrate
```

#### Manual Setup
If you prefer to set up tables manually, run the SQL script:
```bash
psql -d your_database_name -f scripts/setup-db.sql
```

### 5. Verify Setup

Start the development server and test the salt storage functionality:
```bash
npm run dev
```

### 6. Database Schema

The migration includes two tables:

#### `salts` table
- `id`: Unique identifier
- `token_id`: NFT token ID
- `contract_address`: Smart contract address
- `salt`: Cryptographic salt
- `uid_hash`: Hashed UID
- `uid_code`: Product code
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

#### `vaults` table
- `id`: Unique identifier
- `address`: Vault address
- `data`: Vault data
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

### 7. Development Tools

- **Prisma Studio**: `npm run db:studio` - Visual database browser
- **Generate Client**: `npm run db:generate` - Update Prisma client
- **Push Schema**: `npm run db:push` - Sync schema changes
- **Create Migration**: `npm run db:migrate` - Create new migration

### 8. Production Deployment

For production, ensure your `DATABASE_URL` is set in your hosting platform's environment variables.

### 9. Data Migration (if needed)

If you have existing data in Supabase, you can export it and import it into PostgreSQL:

```sql
-- Export from Supabase
SELECT * FROM your_supabase_table;

-- Import to PostgreSQL
INSERT INTO salts (token_id, contract_address, salt, uid_hash, uid_code)
VALUES (...);
``` 