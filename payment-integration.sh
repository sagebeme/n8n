#!/bin/bash

# Payment Integration Script for n8n Trial System
# This script handles payment verification and trial activation

# Configuration
PAYMENT_WEBHOOK_PORT=3001
TRIAL_MANAGER_PATH="/usr/local/bin/trial-manager.sh"
LOG_FILE="/var/log/payment-webhook.log"

# Payment processor configuration (replace with your actual settings)
STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY:-sk_test_your_stripe_secret_key}"
PAYPAL_CLIENT_ID="${PAYPAL_CLIENT_ID:-your_paypal_client_id}"
PAYPAL_CLIENT_SECRET="${PAYPAL_CLIENT_SECRET:-your_paypal_client_secret}"

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Generate license key
generate_license_key() {
    local payment_id="$1"
    local timestamp=$(date +%s)
    local random=$(openssl rand -hex 8)
    echo "TRIAL-${payment_id}-${timestamp}-${random}" | tr '[:lower:]' '[:upper:]'
}

# Verify Stripe payment
verify_stripe_payment() {
    local payment_intent_id="$1"
    
    if [ -z "$STRIPE_SECRET_KEY" ] || [ "$STRIPE_SECRET_KEY" = "sk_test_your_stripe_secret_key" ]; then
        log_message "ERROR: Stripe secret key not configured"
        return 1
    fi
    
    # Verify payment with Stripe API
    local response=$(curl -s -u "$STRIPE_SECRET_KEY:" \
        "https://api.stripe.com/v1/payment_intents/$payment_intent_id")
    
    local status=$(echo "$response" | jq -r '.status // "unknown"')
    
    if [ "$status" = "succeeded" ]; then
        log_message "Stripe payment verified: $payment_intent_id"
        return 0
    else
        log_message "Stripe payment failed: $payment_intent_id (status: $status)"
        return 1
    fi
}

# Verify PayPal payment
verify_paypal_payment() {
    local order_id="$1"
    
    if [ -z "$PAYPAL_CLIENT_ID" ] || [ -z "$PAYPAL_CLIENT_SECRET" ]; then
        log_message "ERROR: PayPal credentials not configured"
        return 1
    fi
    
    # Get access token
    local token_response=$(curl -s -X POST \
        "https://api-m.sandbox.paypal.com/v1/oauth2/token" \
        -H "Accept: application/json" \
        -H "Accept-Language: en_US" \
        -u "$PAYPAL_CLIENT_ID:$PAYPAL_CLIENT_SECRET" \
        -d "grant_type=client_credentials")
    
    local access_token=$(echo "$token_response" | jq -r '.access_token')
    
    if [ "$access_token" = "null" ] || [ -z "$access_token" ]; then
        log_message "ERROR: Failed to get PayPal access token"
        return 1
    fi
    
    # Verify order
    local order_response=$(curl -s -X GET \
        "https://api-m.sandbox.paypal.com/v2/checkout/orders/$order_id" \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: application/json")
    
    local status=$(echo "$order_response" | jq -r '.status // "unknown"')
    
    if [ "$status" = "APPROVED" ] || [ "$status" = "COMPLETED" ]; then
        log_message "PayPal payment verified: $order_id"
        return 0
    else
        log_message "PayPal payment failed: $order_id (status: $status)"
        return 1
    fi
}

# Process payment webhook
process_payment_webhook() {
    local payment_data="$1"
    
    # Parse payment data (adjust based on your webhook format)
    local payment_id=$(echo "$payment_data" | jq -r '.payment_id // .id // ""')
    local payment_method=$(echo "$payment_data" | jq -r '.payment_method // "stripe"')
    local amount=$(echo "$payment_data" | jq -r '.amount // 0')
    local currency=$(echo "$payment_data" | jq -r '.currency // "usd"')
    local customer_email=$(echo "$payment_data" | jq -r '.customer_email // ""')
    
    log_message "Processing payment: $payment_id (method: $payment_method, amount: $amount $currency)"
    
    # Verify payment based on method
    local verification_result=1
    case "$payment_method" in
        "stripe")
            verify_stripe_payment "$payment_id"
            verification_result=$?
            ;;
        "paypal")
            verify_paypal_payment "$payment_id"
            verification_result=$?
            ;;
        *)
            log_message "Unknown payment method: $payment_method"
            verification_result=1
            ;;
    esac
    
    if [ $verification_result -eq 0 ]; then
        # Generate license key
        local license_key=$(generate_license_key "$payment_id")
        
        # Activate trial
        if "$TRIAL_MANAGER_PATH" verify "$payment_id" "$license_key"; then
            log_message "Trial activated successfully for payment: $payment_id, license: $license_key"
            
            # Send confirmation email (optional)
            if [ -n "$customer_email" ]; then
                send_confirmation_email "$customer_email" "$license_key"
            fi
            
            return 0
        else
            log_message "Failed to activate trial for payment: $payment_id"
            return 1
        fi
    else
        log_message "Payment verification failed for: $payment_id"
        return 1
    fi
}

# Send confirmation email (optional)
send_confirmation_email() {
    local email="$1"
    local license_key="$2"
    
    # This is a placeholder - implement your email service
    log_message "Sending confirmation email to: $email with license: $license_key"
    
    # Example using curl with an email service like SendGrid, Mailgun, etc.
    # curl -X POST "https://api.sendgrid.com/v3/mail/send" \
    #     -H "Authorization: Bearer YOUR_SENDGRID_API_KEY" \
    #     -H "Content-Type: application/json" \
    #     -d '{
    #         "personalizations": [{"to": [{"email": "'"$email"'"}], "subject": "n8n Trial Activated"}],
    #         "from": {"email": "noreply@yourdomain.com"},
    #         "content": [{"type": "text/plain", "value": "Your n8n trial has been activated! License Key: '"$license_key"'"}]
    #     }'
}

# Start webhook server
start_webhook_server() {
    log_message "Starting payment webhook server on port $PAYMENT_WEBHOOK_PORT"
    
    # Simple HTTP server using netcat (replace with proper web server in production)
    while true; do
        echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"status\":\"webhook_server_running\"}" | \
        nc -l -p "$PAYMENT_WEBHOOK_PORT" -q 1 | while read -r line; do
            if [[ "$line" =~ POST.*webhook ]]; then
                # Extract JSON payload (simplified - use proper HTTP parsing in production)
                local payload=$(echo "$line" | grep -o '{.*}')
                if [ -n "$payload" ]; then
                    process_payment_webhook "$payload"
                fi
            fi
        done
    done
}

# Manual trial activation
manual_activate_trial() {
    local payment_id="$1"
    local license_key="$2"
    
    if [ -z "$payment_id" ] || [ -z "$license_key" ]; then
        echo "Usage: $0 manual-activate <payment_id> <license_key>"
        return 1
    fi
    
    log_message "Manual trial activation: payment_id=$payment_id, license_key=$license_key"
    
    if "$TRIAL_MANAGER_PATH" verify "$payment_id" "$license_key"; then
        echo "Trial activated successfully!"
        log_message "Manual trial activation successful: $payment_id"
        return 0
    else
        echo "Failed to activate trial"
        log_message "Manual trial activation failed: $payment_id"
        return 1
    fi
}

# Check trial status
check_trial_status() {
    if "$TRIAL_MANAGER_PATH" check; then
        echo "Trial is active"
        return 0
    else
        echo "Trial is expired or not found"
        return 1
    fi
}

# Main function
case "$1" in
    "start-webhook")
        start_webhook_server
        ;;
    "manual-activate")
        manual_activate_trial "$2" "$3"
        ;;
    "check-status")
        check_trial_status
        ;;
    "verify-payment")
        process_payment_webhook "$2"
        ;;
    *)
        echo "n8n Trial Payment Integration Script"
        echo ""
        echo "Usage: $0 {start-webhook|manual-activate|check-status|verify-payment}"
        echo ""
        echo "Commands:"
        echo "  start-webhook                    - Start payment webhook server"
        echo "  manual-activate <payment_id> <license_key> - Manually activate trial"
        echo "  check-status                     - Check current trial status"
        echo "  verify-payment <json_payload>    - Verify payment and activate trial"
        echo ""
        echo "Environment Variables:"
        echo "  STRIPE_SECRET_KEY               - Stripe secret key for payment verification"
        echo "  PAYPAL_CLIENT_ID               - PayPal client ID"
        echo "  PAYPAL_CLIENT_SECRET           - PayPal client secret"
        echo ""
        echo "Example:"
        echo "  $0 manual-activate pay_123456789 TRIAL-PAY123-1234567890-ABC123"
        ;;
esac
