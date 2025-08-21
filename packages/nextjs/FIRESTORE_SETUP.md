# Firebase Firestore Setup (Server-side Only)

This project now supports Firebase Firestore as a database option alongside Supabase and PostgreSQL (Prisma). This implementation uses the Firebase Admin SDK for secure server-side operations only.

## Setup Instructions

### 1. Firebase Project Setup

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Enable Firestore Database in your project
4. Go to Project Settings > Service Accounts
5. Generate a new private key (this will download a JSON file)
6. Use the values from the JSON file for your environment variables

### 2. Environment Variables

Add the following environment variables to your `.env.local` file:

```env
# Enable Firestore
USE_FIRESTORE=true

# Firebase Admin SDK Configuration (from service account JSON)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_CLIENT_EMAIL=your_service_account_email
FIREBASE_PRIVATE_KEY=your_private_key
```

**Important**: These are server-side environment variables and will not be exposed to the client.

### 3. Install Dependencies

The Firebase Admin SDK is already included in the package.json. Run:

```bash
npm install
```

### 4. Deploy Firestore Rules and Indexes

Deploy the Firestore security rules and indexes:

```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes
```

### 5. Database Switching

The application supports three database options:

- **Supabase**: Set `NEXT_PUBLIC_USE_SUPABASE=true`
- **Firestore**: Set `USE_FIRESTORE=true`
- **PostgreSQL (Prisma)**: Set both to `false`

## Data Models

### Salt Collection
```typescript
interface SaltData {
  id?: string;
  tokenId: string;
  contractAddress: string;
  salt: string;
  uidHash: string;
  uidCode: string;
  createdAt?: Date;
  updatedAt?: Date;
}
```

### Vault Collection
```typescript
interface VaultData {
  id?: string;
  address: string;
  data: string;
  createdAt?: Date;
  updatedAt?: Date;
}
```

## Usage

The Firestore operations are handled through API routes for security. The following operations are available:

### Salt Operations
- `POST /api/salt` - Create a new salt record
- `GET /api/salt?tokenId=...&contractAddress=...` - Get salt by token and contract

### Server-side Operations (for internal use)
- `saltServiceAdmin.create(data)` - Create a new salt record
- `saltServiceAdmin.getByTokenAndContract(tokenId, contractAddress)` - Get salt by token and contract
- `saltServiceAdmin.getAll()` - Get all salts
- `saltServiceAdmin.update(id, data)` - Update a salt record
- `saltServiceAdmin.delete(id)` - Delete a salt record

### Vault Operations
- `vaultServiceAdmin.create(data)` - Create a new vault record
- `vaultServiceAdmin.getByAddress(address)` - Get vault by address
- `vaultServiceAdmin.getById(id)` - Get vault by ID
- `vaultServiceAdmin.getAll()` - Get all vaults
- `vaultServiceAdmin.update(id, data)` - Update a vault record
- `vaultServiceAdmin.delete(id)` - Delete a vault record

## Development

### Local Development

For local development, you can use the Firebase emulators or connect directly to your Firebase project. The server-side implementation doesn't require special emulator setup since it uses the Admin SDK.

### Security Rules

Since we're using the Firebase Admin SDK on the server side, the security rules are less critical as the Admin SDK bypasses them. However, you should still set up proper rules for any direct client access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /salts/{document} {
      allow read, write: if false; // Only allow server-side access
    }
    
    match /vaults/{document} {
      allow read, write: if false; // Only allow server-side access
    }
  }
}
```

## Migration from Prisma

If you're migrating from Prisma to Firestore:

1. Export your data from the existing database
2. Use the Firestore service functions to import the data
3. Update your environment variables to use Firestore
4. Test thoroughly before switching in production

## Troubleshooting

### Common Issues

1. **Firebase not initialized**: Make sure all environment variables are set correctly
2. **Permission denied**: Check your Firestore security rules
3. **Index errors**: Deploy the required indexes using `firebase deploy --only firestore:indexes`

### Debug Mode

You can check which database is currently being used by importing the `currentDatabase` variable:

```typescript
import { currentDatabase } from './lib/database';
console.log('Current database:', currentDatabase);
``` 