-- Create salts table
CREATE TABLE IF NOT EXISTS salts (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    token_id TEXT NOT NULL,
    contract_address TEXT NOT NULL,
    salt TEXT NOT NULL,
    uid_hash TEXT NOT NULL,
    uid_code TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create vaults table
CREATE TABLE IF NOT EXISTS vaults (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    address TEXT UNIQUE NOT NULL,
    data TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_salts_contract_address ON salts(contract_address);
CREATE INDEX IF NOT EXISTS idx_salts_token_id ON salts(token_id);
CREATE INDEX IF NOT EXISTS idx_vaults_address ON vaults(address); 