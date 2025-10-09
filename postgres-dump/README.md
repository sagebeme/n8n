# PostgreSQL Database Migration to Supabase

This folder contains scripts and instructions for migrating your n8n database from Render to Supabase.

## Database Connection Details

**Source (Render):**
```
Host: dpg-d31uspbuibrs739cjibg-a.oregon-postgres.render.com
Database: n8n_db_9kiq
Username: n8n_db_9kiq_user
Password: YOUR_PASSWORD
Port: 5432
```

## Migration Steps

### 1. Create Database Dump

**Option A: Using Docker (Recommended)**
```bash
./dump-database-docker.sh
```

**Option B: Using Local PostgreSQL Client**
```bash
./dump-database.sh
```

**Note**: If you get version compatibility errors, use the Docker version which automatically handles version mismatches.

This will create:
- `n8n_database_dump.sql` - Complete database dump
- `n8n_schema_only.sql` - Schema only (structure)
- `n8n_data_only.sql` - Data only (no structure)

### 2. Set up Supabase

1. Go to [Supabase](https://supabase.com) and create a new project
2. Note your database connection details from the Supabase dashboard
3. Update the `restore-to-supabase.sh` script with your Supabase credentials

### 3. Restore to Supabase

Run the restore script:

```bash
./restore-to-supabase.sh
```

### 4. Update n8n Configuration

Update your n8n configuration to use the new Supabase database:

```bash
# Environment variables for Supabase
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=your-supabase-host
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=postgres
DB_POSTGRESDB_USER=postgres
DB_POSTGRESDB_PASSWORD=your-supabase-password
DB_POSTGRESDB_SCHEMA=public
```

## Files in this folder

- `README.md` - This file
- `dump-database.sh` - Script to dump the database from Render (local client)
- `dump-database-docker.sh` - Script to dump using Docker (recommended)
- `dump-database-compatible.sh` - Alternative script with error handling
- `restore-to-supabase.sh` - Script to restore to Supabase
- `n8n_database_dump.sql` - Complete database dump (created after running dump script)
- `n8n_schema_only.sql` - Schema only dump (created after running dump script)
- `n8n_data_only.sql` - Data only dump (created after running dump script)

## Troubleshooting

### Common Issues

1. **Version compatibility error**: Use `./dump-database-docker.sh` instead of `./dump-database.sh`
2. **Connection timeout**: Check if your IP is whitelisted in Supabase
3. **Permission errors**: Ensure the database user has proper permissions
4. **Schema conflicts**: You may need to drop existing tables in Supabase first
5. **Docker not available**: Install Docker or use the manual approach

### Manual Steps

If the scripts don't work, you can run the commands manually:

```bash
# Dump from Render
pg_dump "postgresql://YOUR_USER:YOUR_PASSWORD@YOUR_RENDER_HOST/YOUR_DATABASE" > n8n_database_dump.sql

# Restore to Supabase
psql "postgresql://postgres:your-password@your-supabase-host:5432/postgres" < n8n_database_dump.sql
```

## Security Notes

- The database password is included in this documentation for migration purposes
- Change the password after migration is complete
- Consider using environment variables for sensitive data
- Never commit actual database credentials to version control

## Next Steps

After successful migration:
1. Test your n8n instance with the new database
2. Update your production environment variables
3. Verify all workflows and data are intact
4. Consider setting up automated backups in Supabase
