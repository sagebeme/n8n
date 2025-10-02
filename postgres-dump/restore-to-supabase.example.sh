#!/bin/bash

# PostgreSQL Database Restore Script for Supabase - EXAMPLE
# This script restores your n8n database dump to Supabase

set -e

echo "Starting PostgreSQL database restore to Supabase..."

# Supabase connection details - REPLACE WITH YOUR SUPABASE CREDENTIALS
SUPABASE_HOST="your-project-ref.supabase.co"
SUPABASE_DATABASE="postgres"
SUPABASE_USER="postgres"
SUPABASE_PASSWORD="your-supabase-password-here"
SUPABASE_PORT="5432"

# Connection string for Supabase
SUPABASE_CONNECTION_STRING="postgresql://${SUPABASE_USER}:${SUPABASE_PASSWORD}@${SUPABASE_HOST}:${SUPABASE_PORT}/${SUPABASE_DATABASE}"

echo "Target database: ${SUPABASE_HOST}/${SUPABASE_DATABASE}"

# Check if required files exist
if [ ! -f "n8n_database_dump.sql" ]; then
    echo "Error: n8n_database_dump.sql not found!"
    echo "Please run ./dump-database-docker.example.sh first to create the dump file."
    exit 1
fi

# Check if psql is available
if ! command -v psql &> /dev/null; then
    echo "Error: psql is not installed."
    echo "Please install PostgreSQL client tools:"
    echo "  Ubuntu/Debian: sudo apt install postgresql-client"
    echo "  macOS: brew install postgresql"
    echo "  Windows: Download from https://www.postgresql.org/download/"
    exit 1
fi

echo ""
echo "⚠️  IMPORTANT: This will overwrite existing data in your Supabase database!"
echo "Make sure you have a backup of your Supabase database before proceeding."
echo ""
read -p "Do you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
echo "🔄 Starting database restore..."

# Test connection first
echo "Testing connection to Supabase..."
if ! PGPASSWORD="$SUPABASE_PASSWORD" psql -h "$SUPABASE_HOST" -p "$SUPABASE_PORT" -U "$SUPABASE_USER" -d "$SUPABASE_DATABASE" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ Failed to connect to Supabase database!"
    echo "Please check your connection details:"
    echo "  Host: $SUPABASE_HOST"
    echo "  Port: $SUPABASE_PORT"
    echo "  Database: $SUPABASE_DATABASE"
    echo "  User: $SUPABASE_USER"
    exit 1
fi

echo "✅ Connection successful!"

# Restore the database
echo ""
echo "📥 Restoring database from dump file..."
echo "This may take several minutes depending on the size of your database..."

if PGPASSWORD="$SUPABASE_PASSWORD" psql -h "$SUPABASE_HOST" -p "$SUPABASE_PORT" -U "$SUPABASE_USER" -d "$SUPABASE_DATABASE" -f "n8n_database_dump.sql"; then
    echo ""
    echo "✅ Database restore completed successfully!"
else
    echo ""
    echo "❌ Database restore failed!"
    echo "Please check the error messages above and try again."
    exit 1
fi

# Verify the restore
echo ""
echo "🔍 Verifying the restore..."

# Check if n8n tables exist
TABLE_COUNT=$(PGPASSWORD="$SUPABASE_PASSWORD" psql -h "$SUPABASE_HOST" -p "$SUPABASE_PORT" -U "$SUPABASE_USER" -d "$SUPABASE_DATABASE" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%n8n%';" 2>/dev/null | tr -d ' ')

if [ "$TABLE_COUNT" -gt 0 ]; then
    echo "✅ Found $TABLE_COUNT n8n-related tables in the database"
else
    echo "⚠️  No n8n tables found. The restore might have failed."
fi

# Show some basic stats
echo ""
echo "📊 Database statistics:"
PGPASSWORD="$SUPABASE_PASSWORD" psql -h "$SUPABASE_HOST" -p "$SUPABASE_PORT" -U "$SUPABASE_USER" -d "$SUPABASE_DATABASE" -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC 
LIMIT 10;
"

echo ""
echo "🎉 Database migration completed!"
echo ""
echo "📋 Next steps:"
echo "1. Update your n8n configuration to use the new Supabase database"
echo "2. Test your workflows to ensure everything is working"
echo "3. Update any webhook URLs if needed"
echo ""
echo "🔗 Supabase connection details for n8n:"
echo "  Host: $SUPABASE_HOST"
echo "  Port: $SUPABASE_PORT"
echo "  Database: $SUPABASE_DATABASE"
echo "  User: $SUPABASE_USER"
echo "  Password: [your password]"
echo ""
echo "💡 You can now use these credentials in your n8n environment variables or docker-compose.yml"
