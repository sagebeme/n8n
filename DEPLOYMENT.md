# n8n Enterprise Docker Deployment Guide

This guide shows you how to build and deploy the n8n enterprise features unlock patch as a Docker image.

## 🐳 Building the Docker Image

### Option 1: Use Pre-built Image (Recommended)

```bash
# Pull the pre-built enterprise image
docker pull sagebeme/n8n-enterprise:latest

# Or use directly in docker-compose
# (No build step needed)
```

### Option 2: Build Locally

```bash
# Build the enterprise image
docker build -f Dockerfile.enterprise -t n8n-enterprise:latest .

# Tag for Docker Hub (replace 'yourusername' with your Docker Hub username)
docker tag n8n-enterprise:latest yourusername/n8n-enterprise:latest

# Push to Docker Hub
docker push yourusername/n8n-enterprise:latest
```

### Option 3: Using Docker Compose

```bash
# Run with pre-built image (recommended)
docker-compose -f docker-compose.enterprise.yml up -d

# Or build and run locally
docker-compose -f docker-compose.enterprise.yml up --build
```

## 🚀 Deploying to Render

### Step 1: Use Pre-built Image (Skip Docker Hub Setup)

The enterprise image is already available on Docker Hub at `sagebeme/n8n-enterprise:latest`. You can use it directly without building or pushing anything.

### Alternative: Build Your Own Image

1. **Create a Docker Hub account** (if you don't have one)
2. **Build and push your image:**

```bash
# Login to Docker Hub
docker login

# Build the enterprise image
docker build -f Dockerfile.enterprise -t yourusername/n8n-enterprise:latest .

# Push to Docker Hub
docker push yourusername/n8n-enterprise:latest
```

### Step 2: Deploy on Render

1. **Go to [Render Dashboard](https://dashboard.render.com)**
2. **Click "New +" → "Web Service"**
3. **Connect your GitHub repository** (or use Docker Hub directly)
4. **Configure the service:**

#### Basic Configuration
- **Name:** `n8n-enterprise`
- **Environment:** `Docker`
- **Docker Image:** `sagebeme/n8n-enterprise:latest`
- **Port:** `5678`

#### Environment Variables
```env
# Database Configuration (use Render's PostgreSQL)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=your-render-postgres-host
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=your-database-name
DB_POSTGRESDB_USER=your-username
DB_POSTGRESDB_PASSWORD=your-password
DB_POSTGRESDB_SCHEMA=public

# n8n Configuration
N8N_RUNNERS_ENABLED=true
N8N_BLOCK_ENV_ACCESS_IN_NODE=false
N8N_GIT_NODE_DISABLE_BARE_REPOS=true

# Production URLs (replace with your domain)
N8N_WEBHOOK_URL=https://your-n8n-app.onrender.com
N8N_EDITOR_BASE_URL=https://your-n8n-app.onrender.com
```

#### Advanced Configuration
- **Instance Type:** `Starter` (free) or `Standard` (paid)
- **Auto-Deploy:** `Yes` (if connected to GitHub)
- **Health Check Path:** `/healthz` (optional)

### Step 3: Set up PostgreSQL on Render

1. **Go to Render Dashboard**
2. **Click "New +" → "PostgreSQL"**
3. **Configure:**
   - **Name:** `n8n-postgres`
   - **Database:** `n8n`
   - **User:** `n8n`
   - **Region:** Same as your web service
4. **Copy the connection details** to your web service environment variables

## 🔧 Alternative Deployment Options

### Railway

1. **Connect GitHub repository**
2. **Add `railway.toml`:**
```toml
[build]
builder = "dockerfile"
dockerfilePath = "Dockerfile.enterprise"

[deploy]
startCommand = "n8n start"
healthcheckPath = "/healthz"
healthcheckTimeout = 300
restartPolicyType = "always"
```

3. **Set environment variables** in Railway dashboard
4. **Deploy**

### DigitalOcean App Platform

1. **Create new app**
2. **Connect GitHub repository**
3. **Configure:**
   - **Source:** GitHub
   - **Docker Image:** `sagebeme/n8n-enterprise:latest`
   - **Port:** `5678`
4. **Add environment variables**
5. **Deploy**

### AWS ECS/Fargate

1. **Use pre-built image** (recommended):
   - **Docker Image:** `sagebeme/n8n-enterprise:latest`

   **OR** build your own:

```bash
# Create ECR repository
aws ecr create-repository --repository-name n8n-enterprise

# Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin your-account.dkr.ecr.us-east-1.amazonaws.com

# Build and push
docker build -f Dockerfile.enterprise -t n8n-enterprise .
docker tag n8n-enterprise:latest your-account.dkr.ecr.us-east-1.amazonaws.com/n8n-enterprise:latest
docker push your-account.dkr.ecr.us-east-1.amazonaws.com/n8n-enterprise:latest
```

2. **Create ECS task definition**
3. **Deploy to Fargate**

## 🛠️ Local Development

### Using Docker Compose

```bash
# Clone the repository
git clone https://github.com/yourusername/n8n.git
cd n8n

# Create environment file
cp env.example .env
# Edit .env with your database credentials

# Start the services
docker-compose -f docker-compose.enterprise.yml up -d

# View logs
docker-compose -f docker-compose.enterprise.yml logs -f

# Stop services
docker-compose -f docker-compose.enterprise.yml down
```

### Using Docker Run

```bash
# Start PostgreSQL
docker run -d --name postgres-n8n \
  -p 5432:5432 \
  -e POSTGRES_DB=n8n \
  -e POSTGRES_USER=n8n \
  -e POSTGRES_PASSWORD=your_password \
  postgres:17

# Start n8n Enterprise
docker run -d --name n8n-enterprise \
  -p 5678:5678 \
  -e DB_TYPE=postgresdb \
  -e DB_POSTGRESDB_HOST=localhost \
  -e DB_POSTGRESDB_PORT=5432 \
  -e DB_POSTGRESDB_DATABASE=n8n \
  -e DB_POSTGRESDB_USER=n8n \
  -e DB_POSTGRESDB_PASSWORD=your_password \
  -e DB_POSTGRESDB_SCHEMA=public \
  -v n8n_data:/home/node/.n8n \
  sagebeme/n8n-enterprise:latest
```

## 🔒 Security Considerations

### Production Deployment

1. **Use strong passwords** for database
2. **Enable SSL/TLS** for database connections
3. **Use environment variables** for sensitive data
4. **Regular backups** of your database
5. **Monitor logs** for security issues
6. **Keep images updated** regularly

### Environment Variables Security

```bash
# Use Render's environment variable encryption
# Never commit .env files to version control
# Use different credentials for different environments
```

## 📊 Monitoring and Logs

### Render
- **Logs:** Available in Render dashboard
- **Metrics:** Basic metrics included
- **Alerts:** Set up in dashboard

### Custom Monitoring
```bash
# Health check endpoint
curl https://your-app.onrender.com/healthz

# View logs
docker logs n8n-enterprise
```

## 🚨 Troubleshooting

### Common Issues

1. **"Database connection failed"**
   - Check database credentials
   - Ensure database is running
   - Verify network connectivity

2. **"Port already in use"**
   - Change port mapping
   - Stop conflicting services

3. **"Image not found"**
   - Ensure image is pushed to registry
   - Check image name and tag

4. **"Enterprise features not working"**
   - Verify patch was applied correctly
   - Check container logs
   - Restart the container

### Debug Commands

```bash
# Check if patch was applied
docker exec n8n-enterprise grep -n "sharing: true" /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js

# View n8n logs
docker logs n8n-enterprise

# Check database connection
docker exec n8n-enterprise n8n user:list
```

## 🎉 Success!

Once deployed, your n8n instance will have all enterprise features unlocked:

- ✅ Workflow Sharing
- ✅ Advanced Execution Filters
- ✅ Variables, Source Control, External Secrets
- ✅ Debug in Editor, Worker View, Advanced Permissions
- ✅ API Key Scopes, Workflow Diffs
- ✅ LDAP/SAML/OIDC, MFA Enforcement, Log Streaming

Access your n8n instance at the provided URL and start automating! 🚀
