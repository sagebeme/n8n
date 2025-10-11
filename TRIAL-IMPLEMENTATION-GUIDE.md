# n8n 30-Day Trial Implementation Guide

This guide shows you how to implement a 30-day trial system for your n8n Docker images with payment integration.

## 🎯 Overview

The system works as follows:
1. Customer pays you (via Stripe, PayPal, etc.)
2. Payment webhook triggers trial activation
3. Customer gets 30 days of full enterprise features
4. After 30 days, features are restricted to Starter plan

## 📦 Components

### 1. Trial Docker Image
- **File**: `Dockerfile.n8n-trial`
- **Image**: `sagebeme/n8n-trial:latest`
- **Features**: All enterprise features enabled for 30 days

### 2. Payment Integration Script
- **File**: `payment-integration.sh`
- **Purpose**: Handles payment verification and trial activation

### 3. Trial Management System
- **Database**: SQLite database for trial tracking
- **Duration**: 30 days from activation
- **Features**: License key generation, expiration tracking

## 🚀 Implementation Steps

### Step 1: Build Trial Docker Image

```bash
# Build the trial image
docker build -f Dockerfile.n8n-trial -t sagebeme/n8n-trial:latest .

# Push to Docker Hub
docker push sagebeme/n8n-trial:latest
```

### Step 2: Set Up Payment Processing

#### Option A: Stripe Integration

1. **Create Stripe Account**: Go to [stripe.com](https://stripe.com)
2. **Get API Keys**: 
   - Secret Key: `sk_live_...` (for production)
   - Publishable Key: `pk_live_...` (for frontend)

3. **Configure Webhook**:
   ```bash
   # Set environment variables
   export STRIPE_SECRET_KEY="sk_live_your_stripe_secret_key"
   ```

#### Option B: PayPal Integration

1. **Create PayPal Developer Account**: Go to [developer.paypal.com](https://developer.paypal.com)
2. **Create App**: Get Client ID and Secret
3. **Configure**:
   ```bash
   export PAYPAL_CLIENT_ID="your_paypal_client_id"
   export PAYPAL_CLIENT_SECRET="your_paypal_client_secret"
   ```

### Step 3: Deploy Trial System

#### Using Docker Compose (Recommended)

Create `docker-compose.trial.yml`:

```yaml
version: '3.8'

services:
  n8n-trial:
    image: sagebeme/n8n-trial:latest
    container_name: n8n-trial
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n_trial
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=your_password
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=admin
    volumes:
      - n8n_trial_data:/home/node/.n8n
    depends_on:
      - postgres
      - payment-webhook

  postgres:
    image: postgres:15
    container_name: postgres-trial
    restart: unless-stopped
    environment:
      - POSTGRES_DB=n8n_trial
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=your_password
    volumes:
      - postgres_trial_data:/var/lib/postgresql/data

  payment-webhook:
    image: sagebeme/n8n-trial:latest
    container_name: payment-webhook
    restart: unless-stopped
    ports:
      - "3001:3001"
    environment:
      - STRIPE_SECRET_KEY=sk_live_your_stripe_secret_key
      - PAYPAL_CLIENT_ID=your_paypal_client_id
      - PAYPAL_CLIENT_SECRET=your_paypal_client_secret
    volumes:
      - ./payment-integration.sh:/usr/local/bin/payment-integration.sh
      - payment_logs:/var/log
    command: ["/usr/local/bin/payment-integration.sh", "start-webhook"]

volumes:
  n8n_trial_data:
  postgres_trial_data:
  payment_logs:
```

#### Using Docker Run

```bash
# Start PostgreSQL
docker run -d --name postgres-trial \
  -e POSTGRES_DB=n8n_trial \
  -e POSTGRES_USER=n8n \
  -e POSTGRES_PASSWORD=your_password \
  -p 5432:5432 \
  postgres:15

# Start n8n Trial
docker run -d --name n8n-trial \
  --link postgres-trial:postgres \
  -e DB_TYPE=postgresdb \
  -e DB_POSTGRESDB_HOST=postgres \
  -e DB_POSTGRESDB_PORT=5432 \
  -e DB_POSTGRESDB_DATABASE=n8n_trial \
  -e DB_POSTGRESDB_USER=n8n \
  -e DB_POSTGRESDB_PASSWORD=your_password \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=admin \
  -p 5678:5678 \
  sagebeme/n8n-trial:latest

# Start Payment Webhook Server
docker run -d --name payment-webhook \
  -e STRIPE_SECRET_KEY=sk_live_your_stripe_secret_key \
  -p 3001:3001 \
  -v ./payment-integration.sh:/usr/local/bin/payment-integration.sh \
  sagebeme/n8n-trial:latest \
  /usr/local/bin/payment-integration.sh start-webhook
```

### Step 4: Configure Payment Webhooks

#### Stripe Webhook Setup

1. **Go to Stripe Dashboard** → Webhooks
2. **Add Endpoint**: `https://yourdomain.com:3001/webhook`
3. **Select Events**:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
4. **Copy Webhook Secret**: `whsec_...`

#### PayPal Webhook Setup

1. **Go to PayPal Developer Dashboard**
2. **Create Webhook**: `https://yourdomain.com:3001/paypal-webhook`
3. **Select Events**:
   - `PAYMENT.CAPTURE.COMPLETED`
   - `PAYMENT.CAPTURE.DENIED`

### Step 5: Test the System

#### Manual Trial Activation

```bash
# Generate a test license key
docker exec n8n-trial /usr/local/bin/trial-manager.sh activate "TRIAL-TEST-123" "test_payment_123"

# Check trial status
docker exec n8n-trial /usr/local/bin/trial-manager.sh check
```

#### Test Payment Webhook

```bash
# Test webhook with curl
curl -X POST http://localhost:3001/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "payment_id": "pi_test_123456789",
    "payment_method": "stripe",
    "amount": 5000,
    "currency": "usd",
    "customer_email": "test@example.com"
  }'
```

## 💰 Pricing Strategy

### Recommended Pricing Tiers

1. **Starter Plan**: $20/month
   - Basic features
   - 1 project, 5 concurrent executions

2. **Pro Plan**: $50/month
   - Advanced features
   - 3 projects, 20 concurrent executions

3. **Business Plan**: $667/month
   - Enterprise features
   - 6 projects, SSO/SAML/LDAP

4. **Enterprise Plan**: Custom pricing
   - All features unlocked
   - Unlimited projects

### Trial-to-Paid Conversion

1. **30-Day Trial**: Full enterprise features
2. **Trial Expiry**: Downgrade to Starter plan
3. **Upgrade Prompt**: Show pricing page
4. **Payment**: Process payment and upgrade

## 🔧 Customization Options

### Modify Trial Duration

Edit `Dockerfile.n8n-trial`:
```dockerfile
ENV N8N_TRIAL_DURATION_DAYS="14"  # Change to 14 days
```

### Add Custom Features

Add to the sed patches in `Dockerfile.n8n-trial`:
```dockerfile
sed -i 's/customFeature: this\.license\.isCustomFeatureEnabled(),/customFeature: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
```

### Custom Payment Processors

Add to `payment-integration.sh`:
```bash
verify_custom_payment() {
    local payment_id="$1"
    # Your custom payment verification logic
    return 0
}
```

## 📊 Monitoring & Analytics

### Track Trial Conversions

```bash
# Check active trials
docker exec n8n-trial sqlite3 /home/node/.n8n/trial.db "SELECT * FROM trial_info WHERE status='active';"

# Check expired trials
docker exec n8n-trial sqlite3 /home/node/.n8n/trial.db "SELECT * FROM trial_info WHERE status='expired';"
```

### Log Analysis

```bash
# View payment logs
docker logs payment-webhook

# View n8n logs
docker logs n8n-trial
```

## 🚨 Security Considerations

1. **Environment Variables**: Never commit API keys to git
2. **Webhook Security**: Verify webhook signatures
3. **Database Security**: Use strong passwords
4. **Network Security**: Use HTTPS in production
5. **Access Control**: Implement proper authentication

## 📈 Scaling Considerations

1. **Database**: Move from SQLite to PostgreSQL for production
2. **Load Balancing**: Use multiple n8n instances
3. **Monitoring**: Implement proper monitoring and alerting
4. **Backup**: Regular database backups
5. **Updates**: Plan for n8n version updates

## 🆘 Troubleshooting

### Common Issues

1. **Trial Not Activating**:
   ```bash
   # Check webhook logs
   docker logs payment-webhook
   
   # Check trial database
   docker exec n8n-trial sqlite3 /home/node/.n8n/trial.db ".schema"
   ```

2. **Payment Verification Failing**:
   ```bash
   # Test API keys
   curl -u "$STRIPE_SECRET_KEY:" https://api.stripe.com/v1/payment_intents
   ```

3. **Features Not Unlocking**:
   ```bash
   # Check n8n logs
   docker logs n8n-trial
   
   # Restart container
   docker restart n8n-trial
   ```

## 📞 Support

For issues with this implementation:
1. Check the logs first
2. Verify environment variables
3. Test payment webhooks
4. Check trial database status

## 🎉 Success Metrics

Track these metrics to measure success:
- Trial activation rate
- Trial-to-paid conversion rate
- Average revenue per user
- Customer lifetime value
- Churn rate

This system provides a complete 30-day trial implementation with payment integration for your n8n Docker images!
