#!/bin/bash

# n8n Enterprise Features Patch Script
# This script applies the enterprise features unlock patch to a running n8n container

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default container name
CONTAINER_NAME=${1:-n8n-enterprise}

echo -e "${GREEN} Applying n8n Enterprise Features Patch${NC}"
echo -e "${YELLOW}Container: ${CONTAINER_NAME}${NC}"

# Check if container exists and is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED} Container '$CONTAINER_NAME' is not running${NC}"
    echo "Please start your n8n container first or specify the correct container name:"
    echo "Usage: $0 [container_name]"
    exit 1
fi

echo -e "${YELLOW} Patching frontend service...${NC}"

# Patch frontend service to enable all enterprise features
docker exec -u root "$CONTAINER_NAME" sed -i 's/sharing: this\.license\.isSharingEnabled(),/sharing: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/logStreaming: this\.license\.isLogStreamingEnabled(),/logStreaming: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/ldap: this\.license\.isLdapEnabled(),/ldap: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/saml: this\.license\.isSamlEnabled(),/saml: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/oidc: this\.licenseState\.isOidcLicensed(),/oidc: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/mfaEnforcement: this\.licenseState\.isMFAEnforcementLicensed(),/mfaEnforcement: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/advancedExecutionFilters: this\.license\.isAdvancedExecutionFiltersEnabled(),/advancedExecutionFilters: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/variables: this\.license\.isVariablesEnabled(),/variables: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/sourceControl: this\.license\.isSourceControlLicensed(),/sourceControl: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/externalSecrets: this\.license\.isExternalSecretsEnabled(),/externalSecrets: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/debugInEditor: this\.license\.isDebugInEditorLicensed(),/debugInEditor: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/workerView: this\.license\.isWorkerViewLicensed(),/workerView: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/advancedPermissions: this\.license\.isAdvancedPermissionsLicensed(),/advancedPermissions: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/apiKeyScopes: this\.license\.isApiKeyScopesEnabled(),/apiKeyScopes: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js
docker exec -u root "$CONTAINER_NAME" sed -i 's/workflowDiffs: this\.licenseState\.isWorkflowDiffsLicensed(),/workflowDiffs: true,/g' /usr/local/lib/node_modules/n8n/dist/services/frontend.service.js

echo -e "${YELLOW} Disabling license checks...${NC}"

# Disable license checks
docker exec -u root "$CONTAINER_NAME" sed -i 's/return this\.manager\?\.hasFeatureEnabled(feature) \?\? false;/return true;/g' /usr/local/lib/node_modules/n8n/dist/license.js

echo -e "${YELLOW} Restarting n8n container...${NC}"

# Restart the container to apply changes
docker restart "$CONTAINER_NAME"

echo -e "${GREEN} Patch applied successfully!${NC}"
echo -e "${GREEN} All enterprise features are now unlocked!${NC}"
echo ""
echo -e "${YELLOW} What's now available:${NC}"
echo "  • Workflow Sharing"
echo "  • Advanced Execution Filters"
echo "  • Variables"
echo "  • Source Control"
echo "  • External Secrets"
echo "  • Debug in Editor"
echo "  • Worker View"
echo "  • Advanced Permissions"
echo "  • API Key Scopes"
echo "  • Workflow Diffs"
echo "  • LDAP/SAML/OIDC"
echo "  • MFA Enforcement"
echo "  • Log Streaming"
echo ""
echo -e "${YELLOW} Access n8n at: http://localhost:5678${NC}"
echo ""
echo -e "${YELLOW}  Note: You may see license SDK errors in the logs. These are cosmetic and don't affect functionality.${NC}"


