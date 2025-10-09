# n8n Enterprise Features Unlock Patch

This repository contains a patch that removes the subscription model from n8n and enables all enterprise features by default.

## 🚀 Features Unlocked

### Core Enterprise Features
- **Workflow Sharing** - Share workflows with team members
- **Advanced Execution Filters** - Filter executions with advanced criteria
- **Variables** - Use variables in workflows
- **External Secrets** - External secret management
- **Debug in Editor** - Debug workflows directly in the editor
- **Worker View** - View and manage workers
- **Advanced Permissions** - Fine-grained permission control
- **API Key Scopes** - Scoped API key management
- **Workflow Diffs** - Compare workflow versions
- **Workflow History** - Track workflow execution history
- **Folders** - Organize workflows in folders
- **Custom Roles** - Create custom user roles

### AI & Automation Features
- **AI Assistant** - AI-powered workflow assistance
- **Ask AI** - AI-powered workflow generation
- **AI Credits** - Unlimited AI usage
- **Community Nodes Custom Registry** - Custom node registry

### Analytics & Insights
- **Insights Dashboard** - Detailed workflow execution analytics
- **Insights Summary** - Workflow performance summaries
- **Insights Hourly Data** - Granular execution data

### Authentication & Security
- **LDAP/SAML/OIDC** - Enterprise authentication
- **MFA Enforcement** - Multi-factor authentication enforcement
- **Log Streaming** - Real-time log streaming

### Infrastructure Features
- **Binary Data S3** - S3 storage for binary data
- **Multiple Main Instances** - Scale across multiple instances
- **Project Roles** - Admin, Editor, Viewer role management

### Note on Source Control
- **Source Control** - Disabled to prevent connection errors (can be enabled via environment variables if needed)

## 📋 Prerequisites

- Docker and Docker Compose
- PostgreSQL database (local or remote)
- Basic knowledge of Docker and environment variables

## 🛠️ Quick Start

### Option 1: Using Docker (Recommended)

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url>
   cd n8n
   ```

2. **Set up your database:**
   
   **For local PostgreSQL:**
   ```bash
   docker run -d --name postgres-n8n \
     -p 5432:5432 \
     -e POSTGRES_DB=n8n \
     -e POSTGRES_USER=n8n \
     -e POSTGRES_PASSWORD=your_password \
     postgres:17
   ```

   **For existing PostgreSQL:**
   - Ensure your database is accessible
   - Note down connection details

3. **Create environment file:**
   ```bash
   cp .env.example .env
   ```

4. **Edit `.env` with your database settings:**
   ```env
   DB_TYPE=postgresdb
   DB_POSTGRESDB_HOST=localhost
   DB_POSTGRESDB_PORT=5432
   DB_POSTGRESDB_DATABASE=n8n
   DB_POSTGRESDB_USER=n8n
   DB_POSTGRESDB_PASSWORD=your_password
   DB_POSTGRESDB_SCHEMA=public
   ```

5. **Run n8n with the patch:**
   ```bash
   docker run -d --name n8n-enterprise \
     --env-file .env \
     -p 5678:5678 \
     -v n8n_data:/home/node/.n8n \
     n8nio/n8n:latest
   ```

6. **Apply the enterprise patch:**
   ```bash
   # Enable all enterprise features
   docker exec -u root n8n-enterprise sed -i 's/sharing: this\.license\.isSharingEnabled(),/sharing: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/logStreaming: this\.license\.isLogStreamingEnabled(),/logStreaming: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/ldap: this\.license\.isLdapEnabled(),/ldap: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/saml: this\.license\.isSamlEnabled(),/saml: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/oidc: this\.licenseState\.isOidcLicensed(),/oidc: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/mfaEnforcement: this\.licenseState\.isMFAEnforcementLicensed(),/mfaEnforcement: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/advancedExecutionFilters: this\.license\.isAdvancedExecutionFiltersEnabled(),/advancedExecutionFilters: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/variables: this\.license\.isVariablesEnabled(),/variables: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/sourceControl: this\.license\.isSourceControlLicensed(),/sourceControl: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/externalSecrets: this\.license\.isExternalSecretsEnabled(),/externalSecrets: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/debugInEditor: this\.license\.isDebugInEditorLicensed(),/debugInEditor: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/workerView: this\.license\.isWorkerViewLicensed(),/workerView: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/advancedPermissions: this\.license\.isAdvancedPermissionsLicensed(),/advancedPermissions: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/apiKeyScopes: this\.license\.isApiKeyScopesEnabled(),/apiKeyScopes: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   docker exec -u root n8n-enterprise sed -i 's/workflowDiffs: this\.licenseState\.isWorkflowDiffsLicensed(),/workflowDiffs: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   
   # Disable license checks
   docker exec -u root n8n-enterprise sed -i 's/return this\.manager\?\.hasFeatureEnabled(feature) \?\? false;/return true;/g' /usr/local/lib/node_modules/n8n/dist/license.js
   ```

7. **Restart n8n:**
   ```bash
   docker restart n8n-enterprise
   ```

8. **Access n8n:**
   Open http://localhost:5678 in your browser

### Option 2: Using Docker Compose

1. **Create `docker-compose.yml`:**
   ```yaml
   version: '3.8'
   
   services:
     postgres:
       image: postgres:17
       environment:
         POSTGRES_DB: n8n
         POSTGRES_USER: n8n
         POSTGRES_PASSWORD: your_password
       ports:
         - "5432:5432"
       volumes:
         - postgres_data:/var/lib/postgresql/data
   
     n8n:
       image: n8nio/n8n:latest
       environment:
         DB_TYPE: postgresdb
         DB_POSTGRESDB_HOST: postgres
         DB_POSTGRESDB_PORT: 5432
         DB_POSTGRESDB_DATABASE: n8n
         DB_POSTGRESDB_USER: n8n
         DB_POSTGRESDB_PASSWORD: your_password
         DB_POSTGRESDB_SCHEMA: public
       ports:
         - "5678:5678"
       volumes:
         - n8n_data:/home/node/.n8n
       depends_on:
         - postgres
   
   volumes:
     postgres_data:
     n8n_data:
   ```

2. **Start services:**
   ```bash
   docker-compose up -d
   ```

3. **Apply the patch:**
   ```bash
   # Run the same sed commands as in Option 1, but use the container name from docker-compose
   docker exec -u root n8n_n8n_1 sed -i 's/sharing: this\.license\.isSharingEnabled(),/sharing: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
   # ... (continue with all other sed commands)
   ```

4. **Restart n8n:**
   ```bash
   docker-compose restart n8n
   ```

## 🔧 Advanced Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_TYPE` | Database type | `postgresdb` |
| `DB_POSTGRESDB_HOST` | Database host | `localhost` |
| `DB_POSTGRESDB_PORT` | Database port | `5432` |
| `DB_POSTGRESDB_DATABASE` | Database name | `n8n` |
| `DB_POSTGRESDB_USER` | Database user | `n8n` |
| `DB_POSTGRESDB_PASSWORD` | Database password | - |
| `DB_POSTGRESDB_SCHEMA` | Database schema | `public` |
| `N8N_RUNNERS_ENABLED` | Enable runners | `true` |
| `N8N_BLOCK_ENV_ACCESS_IN_NODE` | Block env access | `false` |

### Custom Domain/SSL

To use a custom domain with SSL:

```bash
docker run -d --name n8n-enterprise \
  --env-file .env \
  -p 443:5678 \
  -v /path/to/ssl:/etc/ssl/certs \
  -v n8n_data:/home/node/.n8n \
  n8nio/n8n:latest
```

## 🗄️ Database Migration

### From Existing n8n Installation

1. **Export your existing database:**
   ```bash
   pg_dump -h your_host -U your_user -d your_database > n8n_backup.sql
   ```

2. **Import to new database:**
   ```bash
   psql -h localhost -U n8n -d n8n < n8n_backup.sql
   ```

### From Render/Supabase/Other Cloud Providers

1. **Get connection string from your provider**
2. **Update environment variables accordingly**
3. **Run the patch as described above**

### Database Migration Scripts

Use the provided example scripts to migrate your database:

1. **Export from source database:**
   ```bash
   # Copy and edit the example script with your credentials
   cp postgres-dump/dump-database-docker.example.sh postgres-dump/dump-database-docker.sh
   # Edit the script with your actual database credentials
   chmod +x postgres-dump/dump-database-docker.sh
   ./postgres-dump/dump-database-docker.sh
   ```

2. **Import to target database:**
   ```bash
   # Copy and edit the example script with your target credentials
   cp postgres-dump/restore-to-supabase.example.sh postgres-dump/restore-to-supabase.sh
   # Edit the script with your actual target database credentials
   chmod +x postgres-dump/restore-to-supabase.sh
   ./postgres-dump/restore-to-supabase.sh
   ```

**⚠️ Important:** Always use the `.example.sh` versions as templates and never commit scripts with real credentials!

## 🐛 Troubleshooting

### Common Issues

1. **"Credentials could not be decrypted"**
   - This is expected when migrating databases
   - Re-enter credentials in the n8n UI

2. **"License SDK errors"**
   - These are cosmetic and don't affect functionality
   - Enterprise features will still work

3. **"Port already in use"**
   - Change the port mapping: `-p 5679:5678`
   - Or stop the conflicting service

4. **"Database connection failed"**
   - Check database credentials
   - Ensure database is running and accessible
   - Verify firewall settings

### Logs

View n8n logs:
```bash
docker logs n8n-enterprise
```

View PostgreSQL logs:
```bash
docker logs postgres-n8n
```

## 🔒 Security Notes

- Change default passwords
- Use strong database passwords
- Consider using Docker secrets for production
- Regularly update the n8n image
- Backup your database regularly

## 📝 License

This patch is for educational purposes. Please respect n8n's terms of service and licensing.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For issues and questions:
1. Check the troubleshooting section
2. Search existing issues
3. Create a new issue with detailed information

## 🎉 Enjoy Your Enterprise n8n!

All enterprise features are now unlocked and ready to use. Happy automating! 🚀
