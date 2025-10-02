# Supabase Database Upload Guide

## Method 1: Supabase Dashboard (Recommended)

### Step 1: Create Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Sign in with your account
3. Click "New Project"
4. Choose organization and enter project details
5. Set a strong database password
6. Select region (preferably close to your users)
7. Click "Create new project"

### Step 2: Access Database Settings
1. Wait for project creation to complete (2-3 minutes)
2. Go to **Settings** → **Database**
3. Scroll down to **Database reset**
4. Or go to **SQL Editor** for direct queries

### Step 3: Upload Database
1. Go to **SQL Editor**
2. Click "New query"
3. Upload the SQL file:
   - Click the upload icon (📁)
   - Select `n8n_database_dump.sql` (38MB file)
   - Click "Run"

### Step 4: Verify Upload
```sql
-- Check if tables were created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

## Method 2: Using Supabase CLI

### Install Supabase CLI
```bash
# Install via npm
npm install -g supabase

# Or via curl
curl -fsSL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz | tar -xz -C /usr/local/bin
```

### Login and Initialize
```bash
# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-id

# Reset database (optional - clears existing data)
supabase db reset

# Execute the SQL file
supabase db push --file postgres-dump/n8n_database_dump.sql
```

## Method 3: Direct PostgreSQL Connection

### Get Connection String
1. Go to **Settings** → **Database**
2. Copy the **Connection string**
3. Format: `postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres`

### Upload via psql
```bash
# Using psql command
psql "postgresql://postgres:YOUR_PASSWORD@db.YOUR_PROJECT_REF.supabase.co:5432/postgres" < n8n_database_dump.sql
```

### Upload via Docker (Alternative)
```bash
# Using Docker PostgreSQL client
docker run --rm -v $(pwd)/postgres-dump:/dump postgres:17 \
  psql "postgresql://postgres:YOUR_PASSWORD@db.YOUR_PROJECT_REF.supabase.co:5432/postgres" < /dump/n8n_database_dump.sql
```

## Method 4: Using pgAdmin or DBeaver

### Steps
1. Install pgAdmin or DBeaver
2. Connect to Supabase using connection string
3. Run the SQL script through the query tool
4. Execute `n8n_database_dump.sql`

## Troubleshooting

### Common Issues

#### 1. File Size Limit
- Supabase dashboard has file size limits
- Use Supabase CLI for large files (38MB+)
- Or split the dump into smaller files:

```bash
# Split the dump file
split -b 10m n8n_database_dump.sql dump_part_
```

#### 2. Permission Errors
- Ensure your Supabase project is active
- Check database password is correct
- Verify SSL connection requirements

#### 3. Schema Conflicts
- Reset database if needed: **Settings** → **Database** → **Reset database**
- Drop existing schema:
```sql
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```

### Success Verification
After upload, verify the data is there:

```sql
-- Check table count
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';

-- Check user table
SELECT COUNT(*) FROM "user";

-- Check workflow table  
SELECT COUNT(*) FROM workflow;
```

## Environment Variables for n8n

After successful upload, use these environment variables in n8n:

```env
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=db.YOUR_PROJECT_REF.supabase.co
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=postgres
DB_POSTGRESDB_USER=postgres
DB_POSTGRESDB_PASSWORD=YOUR_DATABASE_PASSWORD
DB_POSTGRESDB_SCHEMA=public
DB_POSTGRESDB_SSL_ENABLED=true
```

## Next Steps

1. **Test Connection**: Verify n8n can connect to Supabase
2. **Update n8n Config**: Update environment variables
3. **Deploy**: Use the updated config with your n8n deployment
4. **Migrate Credentials**: You may need to reset encryption keys or migrate credentials

Remember to keep your database password secure and never commit it to version control!

