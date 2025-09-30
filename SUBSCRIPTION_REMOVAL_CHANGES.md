# n8n Subscription Model Removal

This document outlines the changes made to remove the subscription model from n8n and enable all enterprise features by default.

## Changes Made

### 1. License Service (`packages/cli/src/license.ts`)
- **Modified**: All license check methods now return `true` (all features licensed)
- **Modified**: `getValue()` returns unlimited values for all quotas
- **Modified**: `getPlanName()` returns "Enterprise"
- **Modified**: `getConsumerId()` returns "enterprise-free"
- **Modified**: All license management methods are now no-ops
- **Removed**: License manager initialization and validation logic

### 2. Frontend Service (`packages/cli/src/services/frontend.service.ts`)
- **Modified**: All enterprise features are enabled by default in settings
- **Modified**: SSO features (LDAP, SAML, OIDC) are always enabled
- **Modified**: Variables limit is set to unlimited
- **Modified**: Workflow history is enabled when configured

### 3. Cloud Plan Store (`packages/frontend/editor-ui/src/stores/cloudPlan.store.ts`)
- **Modified**: All subscription-related methods are no-ops
- **Modified**: Trial and usage checks always return false/unlimited
- **Modified**: Plan data is always null (no subscription)
- **Modified**: Store is always initialized (no loading state)

### 4. Usage Store (`packages/frontend/editor-ui/src/stores/usage.store.ts`)
- **Modified**: Default plan name is "Enterprise"
- **Modified**: All limits are set to unlimited (-1)
- **Modified**: License activation and trial methods are no-ops
- **Modified**: Store shows no loading state

### 5. License Middleware (`packages/cli/src/public-api/v1/shared/middlewares/global.middleware.ts`)
- **Modified**: `isLicensed()` middleware always allows access

### 6. Controller Registry (`packages/cli/src/controller.registry.ts`)
- **Modified**: License middleware always allows access

### 7. Role Service (`packages/cli/src/services/role.service.ts`)
- **Modified**: `isRoleLicensed()` always returns true

### 8. Enterprise Edition Component (`packages/frontend/editor-ui/src/components/EnterpriseEdition.ee.vue`)
- **Modified**: Always shows content (no feature checks)

### 9. Enterprise Feature Check (`packages/frontend/editor-ui/src/utils/rbac/checks/isEnterpriseFeatureEnabled.ts`)
- **Modified**: Always returns true

## Features Now Available

All enterprise features are now available without subscription:

- **Sharing**: Workflow sharing and collaboration
- **SSO**: LDAP, SAML, OIDC authentication
- **Advanced Permissions**: Role-based access control
- **Log Streaming**: Advanced logging capabilities
- **Variables**: Environment variables management
- **Source Control**: Git integration for workflows
- **External Secrets**: Integration with secret managers
- **Workflow History**: Execution history and debugging
- **Worker View**: Worker monitoring and management
- **API Key Scopes**: Fine-grained API access control
- **Workflow Diffs**: Version comparison for workflows
- **Advanced Execution Filters**: Enhanced execution filtering
- **Debug in Editor**: In-editor debugging capabilities
- **Binary Data S3**: S3 storage for binary data
- **MFA Enforcement**: Multi-factor authentication enforcement
- **Custom Roles**: Custom role creation and management
- **Project Roles**: Project-specific role management
- **AI Assistant**: AI-powered workflow assistance
- **Ask AI**: AI question answering
- **AI Credits**: AI usage credits (unlimited)
- **Folders**: Workflow organization
- **Insights**: Analytics and reporting
- **Community Nodes**: Custom node development
- **Custom NPM Registry**: Private package registry

## Usage Limits

All usage limits are now unlimited:
- **Active Workflows**: Unlimited
- **Executions**: Unlimited
- **Users**: Unlimited
- **Variables**: Unlimited
- **Team Projects**: Unlimited
- **AI Credits**: Unlimited
- **Workflow History**: Unlimited retention

## License Information

- **Plan Name**: Enterprise
- **Consumer ID**: enterprise-free
- **Status**: All features enabled
- **Expiration**: Never expires

## Notes

- The license system is completely disabled
- All enterprise features are available by default
- No subscription or activation is required
- The system reports as "Enterprise Edition" with all features enabled
- All license checks and validations have been bypassed
- Subscription-related UI elements are disabled or hidden

## Testing

To test the changes:
1. Start n8n: `npm run start`
2. Access the web interface
3. Verify all enterprise features are available
4. Check that no subscription prompts appear
5. Confirm unlimited usage limits
6. Test enterprise features like SSO, sharing, etc.

## Reverting Changes

To revert these changes, restore the original files from git:
```bash
git checkout HEAD -- packages/cli/src/license.ts
git checkout HEAD -- packages/cli/src/services/frontend.service.ts
git checkout HEAD -- packages/frontend/editor-ui/src/stores/cloudPlan.store.ts
git checkout HEAD -- packages/frontend/editor-ui/src/stores/usage.store.ts
# ... and other modified files
```
