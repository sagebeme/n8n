#!/bin/bash

# PostgreSQL Database Dump Script (Docker Version) - EXAMPLE
# This script uses Docker to run a compatible pg_dump version
# Solves version compatibility issues between pg_dump and server

set -e

echo "Starting PostgreSQL database dump (Docker Version)..."

# Database connection details - REPLACE WITH YOUR VALUES
DB_HOST="your-database-host.com"
DB_NAME="your_database_name"
DB_USER="your_username"
DB_PASSWORD="your_password_here"
DB_PORT="5432"

# Connection string
CONNECTION_STRING="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

echo "Connecting to database: ${DB_HOST}/${DB_NAME}"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not running."
    echo "Please install Docker or use the manual approach."
    echo ""
    echo "Alternative: Install newer PostgreSQL client manually:"
    echo "1. Download from https://www.postgresql.org/download/"
    echo "2. Or use: sudo apt install postgresql-client-17"
    exit 1
fi

# Create output directory
OUTPUT_DIR="$(dirname "$0")"
mkdir -p "$OUTPUT_DIR"

echo "Output directory: $OUTPUT_DIR"

# Function to run pg_dump with Docker
run_pg_dump() {
    local format="$1"
    local output_file="$2"
    local additional_args="$3"
    
    echo "Creating $format dump..."
    
    docker run --rm \
        -v "$OUTPUT_DIR:/output" \
        postgres:17 \
        pg_dump \
        --host="$DB_HOST" \
        --port="$DB_PORT" \
        --username="$DB_USER" \
        --dbname="$DB_NAME" \
        --format="$format" \
        --verbose \
        --no-password \
        $additional_args \
        --file="/output/$output_file" \
        "PGPASSWORD=$DB_PASSWORD"
    
    if [ $? -eq 0 ]; then
        echo "✅ $format dump created successfully: $output_file"
        ls -lh "$OUTPUT_DIR/$output_file"
    else
        echo "❌ Failed to create $format dump"
        exit 1
    fi
}

# Create different types of dumps
echo ""
echo "Creating database dumps..."

# 1. Complete dump (SQL format)
run_pg_dump "plain" "n8n_database_dump.sql" ""

# 2. Schema only
run_pg_dump "plain" "n8n_schema_only.sql" "--schema-only"

# 3. Data only
run_pg_dump "plain" "n8n_data_only.sql" "--data-only"

# 4. Custom format (for faster restore)
run_pg_dump "custom" "n8n_database_dump.custom" ""

# 5. Directory format (for large databases)
run_pg_dump "directory" "n8n_database_dump_dir" ""

echo ""
echo "🎉 All dumps completed successfully!"
echo ""
echo "📁 Files created:"
ls -lh "$OUTPUT_DIR"/*.sql "$OUTPUT_DIR"/*.custom 2>/dev/null || true
ls -ld "$OUTPUT_DIR"/*_dir 2>/dev/null || true

echo ""
echo "📋 Next steps:"
echo "1. Review the dump files"
echo "2. Use restore-to-supabase.example.sh to import to Supabase"
echo "3. Or use psql to restore to your local PostgreSQL"
echo ""
echo "💡 Tips:"
echo "- The .sql files are human-readable"
echo "- The .custom file is faster to restore"
echo "- The _dir folder contains multiple files for large databases"
echo ""
echo "🔒 Security: Remember to delete these files after migration if they contain sensitive data!"


