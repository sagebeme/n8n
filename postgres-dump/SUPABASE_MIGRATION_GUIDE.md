# Supabase Migration Instructions

## Step-by-Step Guide to Migrate from Render to Supabase

### Prerequisites

1. **Install PostgreSQL client tools** (if not already installed):
   ```bash
   # Ubuntu/Debian
   sudo apt-get install postgresql-client
   
   # macOS
   brew install postgresql
   
   # Windows
   # Download from https://www.postgresql.org/download/
   ```

2. **Create a Supabase account** at [supabase.com](https://supabase.com)

### Step 1: Create Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: `n8n-database` (or your preferred name)
   - **Database Password**: Generate a strong password
   - **Region**: Choose closest to your location
5. Click "Create new project"
6. Wait for the project to be created (2-3 minutes)

### Step 2: Get Supabase Connection Details

1. In your Supabase project dashboard, go to **Settings** → **Database**
2. Copy the following details:
   - **Host**: `db.xxxxxxxxxxxxx.supabase.co`
   - **Database name**: `postgres`
   - **Port**: `5432`
   - **User**: `postgres`
   - **Password**: (the one you created)

### Step 3: Update the Restore Script

1. Open `restore-to-supabase.sh` in a text editor
2. Update these variables with your Supabase details:
   ```bash
   SUPABASE_HOST="your-actual-host.supabase.co"
   SUPABASE_PASSWORD="your-actual-password"
   ```

### Step 4: Create Database Dump

Run the dump script to export your current database from Render:

```bash
cd postgres-dump
./dump-database.sh
```

This will create:
- `n8n_database_dump.sql` - Complete database dump
- `n8n_schema_only.sql` - Schema only
- `n8n_data_only.sql` - Data only
- `database_size_info.txt` - Table sizes
- `migration_summary.txt` - Summary

### Step 5: Restore to Supabase

Run the restore script to import your data to Supabase:

```bash
./restore-to-supabase.sh
```

This will:
- Test connection to Supabase
- Restore your database
- Create verification files
- Generate n8n configuration

### Step 6: Update n8n Configuration

After successful restore, update your n8n environment variables:

```bash
# Copy the configuration from the generated file
cat n8n_supabase_config.env
```

Add these to your n8n environment:

```bash
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=your-host.supabase.co
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=postgres
DB_POSTGRESDB_USER=postgres
DB_POSTGRESDB_PASSWORD=your-password
DB_POSTGRESDB_SCHEMA=public
DB_POSTGRESDB_SSL_ENABLED=true
DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false
```

### Step 7: Test the Migration

1. **Restart your n8n instance** with the new database configuration
2. **Check the logs** for any connection errors
3. **Verify workflows** are still there
4. **Test a workflow** to ensure everything works
5. **Check data integrity** by comparing record counts

### Step 8: Update Production (if applicable)

If this is for production:

1. **Schedule maintenance window**
2. **Create final backup** of Render database
3. **Update production environment** variables
4. **Restart production n8n**
5. **Monitor for issues**
6. **Update DNS/connection strings** if needed

### Troubleshooting

#### Connection Issues
- **Check IP whitelist**: Supabase may block your IP
- **Verify credentials**: Double-check host, password, etc.
- **Test connection**: Use `psql` to test manually

#### Permission Issues
- **Check user permissions**: Ensure postgres user has proper access
- **Schema conflicts**: May need to drop existing tables first

#### Data Issues
- **Check encoding**: Ensure UTF-8 encoding
- **Verify constraints**: Check for foreign key violations
- **Test queries**: Run sample queries to verify data

### Manual Commands (if scripts fail)

```bash
# Dump from Render
pg_dump "postgresql://n8n_db_9kiq_user:9Hhji1tURxkvAo4sIPFhB0xR8TYX3Pp4@dpg-d31uspbuibrs739cjibg-a.oregon-postgres.render.com/n8n_db_9kiq" > n8n_database_dump.sql

# Restore to Supabase
psql "postgresql://postgres:your-password@your-host.supabase.co:5432/postgres" < n8n_database_dump.sql
```

### Security Best Practices

1. **Change passwords** after migration
2. **Use environment variables** for sensitive data
3. **Enable SSL** connections
4. **Set up automated backups** in Supabase
5. **Monitor access logs**
6. **Use connection pooling** for production

### Cost Considerations

- **Supabase Free Tier**: 500MB database, 2GB bandwidth
- **Pro Plan**: $25/month for larger databases
- **Render**: Check your current usage and costs

### Rollback Plan

If issues occur:
1. **Keep Render database** running during transition
2. **Test thoroughly** before switching
3. **Have rollback procedure** ready
4. **Monitor both databases** initially

### Support Resources

- **Supabase Docs**: [supabase.com/docs](https://supabase.com/docs)
- **n8n Docs**: [docs.n8n.io](https://docs.n8n.io)
- **PostgreSQL Docs**: [postgresql.org/docs](https://postgresql.org/docs)


