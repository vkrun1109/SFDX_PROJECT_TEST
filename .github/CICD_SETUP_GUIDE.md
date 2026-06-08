# GitHub Actions CI/CD Pipeline for Salesforce & Vlocity Delta Changes

## Complete Setup Guide

This document provides everything needed to set up a production-ready CI/CD pipeline for Salesforce and Vlocity changes using GitHub Actions.

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Repository Setup](#repository-setup)
4. [Secrets Configuration](#secrets-configuration)
5. [Workflow Triggers](#workflow-triggers)
6. [Pipeline Stages](#pipeline-stages)
7. [Environment Configuration](#environment-configuration)

## Overview

### Pipeline Architecture
```
Code Changes → Delta Detection → Validation → Quality Checks → Deploy → Monitor
     ↓              ↓                ↓              ↓           ↓         ↓
   Git Push    Analyze Changes   Syntax Check   Security      Env       Report
                Salesforce/         Lint        Scan        Deploy     Health
                Vlocity              
```

### Supported Components
- **Salesforce**: Apex, Visualforce, LWC, Configuration, Metadata
- **Vlocity**: Omniscripts, DataRaptors, Cards, Catalogs, Integrations
- **Deployment**: Dev → Staging → Production with Rollback

## Prerequisites

### Required Tools
- GitHub repository with Actions enabled
- Salesforce Developer Edition or Production org
- Salesforce CLI (v2.x or higher)
- Vlocity CLI (optional, for Vlocity deployments)
- Node.js 18.x or higher

### Repository Structure
```
your-repo/
├── .github/
│   ├── workflows/
│   │   ├── 01-delta-detection.yml
│   │   ├── 02-salesforce-validation.yml
│   │   ├── 03-vlocity-validation.yml
│   │   ├── 04-code-quality-security-scan.yml
│   │   ├── 05-deploy-dev.yml
│   │   ├── 06-deploy-staging.yml
│   │   ├── 07-deploy-production.yml
│   │   ├── 08-rollback-production.yml
│   │   ├── 09-weekly-delta-report.yml
│   │   └── 10-pipeline-monitoring.yml
│   └── scripts/ (optional)
│
├── force-app/
│   ├── main/
│   │   └── default/
│   │       ├── classes/
│   │       ├── triggers/
│   │       ├── pages/
│   │       ├── components/
│   │       └── ... (other metadata)
│
├── vlocity/
│   ├── OmniScripts/
│   ├── DataRaptors/
│   ├── Cards/
│   └── ... (Vlocity components)
│
├── sfdx-project.json
├── package.json
└── README.md
```

## Repository Setup

### 1. Enable GitHub Actions
- Go to repository Settings → Actions
- Ensure "Allow all actions and reusable workflows" is selected

### 2. Create Branch Protection Rules (Recommended)
- Main branch: Require PR reviews, passing status checks
- Staging branch: Require PR reviews, passing tests
- Develop branch: Require status checks

### 3. Set Up Environments
Go to Settings → Environments and create:
- **dev**: Development org
- **staging**: Staging org  
- **production**: Production org

For each environment:
- Add reviewers for approval
- Add required secrets

## Secrets Configuration

### Required Repository Secrets

#### Salesforce Authentication URLs
```bash
# For each org, generate SFDX auth URL:
sf auth:web:login --set-default-dev-hub --alias DevHub
sf auth:store:sfdx-url -f <auth-file> -a <alias>
sf auth:sfdx:url:compute
```

**Add these secrets to GitHub:**

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `SALESFORCE_DEV_AUTH_URL` | Dev org auth URL | `force://...` |
| `SALESFORCE_STAGING_AUTH_URL` | Staging org auth URL | `force://...` |
| `SALESFORCE_PROD_AUTH_URL` | Production org auth URL | `force://...` |

#### Optional Vlocity Secrets
```yaml
VLOCITY_ORG_ALIAS: prod-org
VLOCITY_AUTH_TOKEN: <optional-token>
```

### How to Add Secrets

1. Go to repository **Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Enter Secret name and value
4. Click **Add secret**

**Automated Setup Script:**
```bash
#!/bin/bash
# setup-secrets.sh

# Get auth URLs from orgs
DEV_AUTH=$(sf auth sfdx:url:compute --alias dev-org)
STAGING_AUTH=$(sf auth sfdx:url:compute --alias staging-org)
PROD_AUTH=$(sf auth sfdx:url:compute --alias prod-org)

# Add to GitHub (requires gh CLI)
gh secret set SALESFORCE_DEV_AUTH_URL -b "$DEV_AUTH"
gh secret set SALESFORCE_STAGING_AUTH_URL -b "$STAGING_AUTH"
gh secret set SALESFORCE_PROD_AUTH_URL -b "$PROD_AUTH"

echo "Secrets configured successfully!"
```

## Workflow Triggers

### Trigger Matrix

| Workflow | Trigger | Branch | Condition |
|----------|---------|--------|-----------|
| Delta Detection | PR opened/sync, Push | main, develop | force-app/** or vlocity/** |
| Salesforce Validation | Delta Detection complete, PR | - | force-app/** changes |
| Vlocity Validation | Delta Detection complete, PR | - | vlocity/** changes |
| Code Quality | PR opened/sync | - | force-app/** or vlocity/** |
| Deploy Dev | Push | develop | force-app/** or vlocity/** |
| Deploy Staging | Push | staging | force-app/** or vlocity/** |
| Deploy Production | Push | main | force-app/** or vlocity/** |
| Rollback | Manual dispatch | - | On-demand |
| Weekly Report | Schedule (Mon 9 AM UTC) | - | Automated |
| Monitoring | Schedule (30 min), Workflow complete | - | Continuous |

### Manual Trigger Examples

```bash
# Trigger rollback workflow
gh workflow run 08-rollback-production.yml \
  -f backup_id=20240115_143022 \
  -f reason="Critical bug detected"

# Trigger production deployment
gh workflow run 07-deploy-production.yml \
  --ref main
```

## Pipeline Stages

### Stage 1: Delta Detection
**Purpose**: Identify what changed between commits

**Outputs:**
- Changed file list
- Delta count by type
- Modified metadata types
- Component impact analysis

**Example Output:**
```
Modified Salesforce Files:
- force-app/main/default/classes/AccountController.cls (M)
- force-app/main/default/triggers/AccountTrigger.trigger (M)
- force-app/main/default/objects/Account/Account.object-meta.xml (M)

Modified Vlocity Files:
- vlocity/OmniScripts/OSAccountSetup.json (M)
- vlocity/DataRaptors/DRCustomerData.json (A)
```

### Stage 2: Salesforce Validation
**Purpose**: Validate Salesforce metadata structure and syntax

**Checks:**
- ✓ sfdx-project.json validation
- ✓ XML syntax validation
- ✓ Metadata structure validation
- ✓ Apex class naming conventions
- ✓ Trigger validation
- ✓ Component count analysis

**Failure Conditions:**
- Invalid XML
- Missing metadata files
- Syntax errors in Apex

### Stage 3: Vlocity Validation
**Purpose**: Validate Vlocity component structure

**Checks:**
- ✓ JSON syntax validation
- ✓ Required fields check (type, Name)
- ✓ Component dependency analysis
- ✓ Size validation
- ✓ Structure validation

**Failure Conditions:**
- Invalid JSON
- Missing required fields
- Circular dependencies

### Stage 4: Code Quality & Security
**Purpose**: Ensure code quality and security standards

**Scans:**
- ✓ Hardcoded credentials detection
- ✓ Security vulnerability scan
- ✓ Code complexity analysis
- ✓ Duplicate code detection
- ✓ Coding standards validation
- ✓ npm dependency audit

### Stage 5: Deploy to Dev
**Purpose**: Deploy to development environment

**Process:**
1. Create backup of dev org
2. Deploy Salesforce metadata
3. Deploy Vlocity components
4. Verify deployment
5. Post-deployment validation

### Stage 6: Deploy to Staging
**Purpose**: Deploy to staging with full validation

**Process:**
1. Create backup of staging org
2. Validation deploy (no actual deploy)
3. Deploy with test-level: RunLocalTests
4. Run Apex tests
5. Smoke tests
6. Generate reports

### Stage 7: Deploy to Production
**Purpose**: Safe production deployment with approval gates

**Process:**
1. Pre-deployment approval checks
2. Full production backup
3. Validation deployment (all tests)
4. Production deployment
5. Post-deployment verification
6. Comprehensive reporting

### Stage 8: Rollback
**Purpose**: Emergency rollback to previous state

**Process:**
1. Verify rollback request
2. Download backup
3. Check backup integrity
4. Deploy backup metadata
5. Verify rollback success
6. Generate incident report

### Stage 9: Reporting
**Purpose**: Weekly metrics and analytics

**Reports:**
- Delta changes summary
- Deployment metrics
- Code quality trends
- Component statistics

### Stage 10: Monitoring
**Purpose**: Continuous pipeline health monitoring

**Monitoring:**
- Workflow status checks
- Secret configuration validation
- Performance metrics
- Success rates

## Environment Configuration

### Development Environment

**Org Setup:**
```bash
sf org:create:scratch --definition-file config/project-scratch-def.json \
  --alias dev-org --duration-days 30

# Create auth URL for GitHub secret
sf auth:store:sfdx-url -f <auth-file> -a dev-org
```

**Deployment Strategy:**
- Frequent deployments (daily)
- Quick feedback cycle
- No approval required
- Direct deploy, no tests

### Staging Environment

**Org Setup:**
```bash
# Sandbox org (not scratch)
sf org:login:web --set-default --alias staging-org
```

**Deployment Strategy:**
- Controlled deployments (weekly)
- Test-level: RunLocalTests
- Validation deploy before actual deploy
- Smoke testing

### Production Environment

**Org Setup:**
```bash
# Production org
sf org:login:web --set-default --alias prod-org
```

**Deployment Strategy:**
- Controlled deployments (scheduled)
- Full backup before deploy
- Validation deploy first
- All tests must pass
- Requires approval
- Automatic rollback capability

---

## Quick Start

### 1. Clone Workflows
Copy all 10 workflow files to `.github/workflows/`

### 2. Configure Secrets
```bash
bash setup-secrets.sh
```

### 3. Create Branches
```bash
git branch develop
git branch staging
git push -u origin develop staging
```

### 4. Push First Commit
```bash
git add .github/
git commit -m "Add CI/CD workflows"
git push origin main
```

### 5. Create Pull Request
```bash
git checkout -b feature/test-deployment
echo "test" > test.txt
git push -u origin feature/test-deployment
# Create PR in GitHub - triggers delta detection
```

### 6. Monitor Workflows
- Go to Actions tab
- Watch workflows execute
- Check job logs
- Review reports

---

## Troubleshooting

### Common Issues

**Workflow not triggered:**
- Check branch name matches trigger
- Verify file paths match glob pattern
- Check file actually changed

**Authentication fails:**
- Verify SFDX auth URL is valid
- Check secret is set correctly
- Ensure org credentials are valid

**Deployment fails:**
- Check logs for error details
- Verify metadata is valid
- Check org limits
- Review test failures

**Rollback needed:**
- Use 08-rollback-production.yml workflow
- Provide backup ID and reason
- Monitor post-rollback validation

---

## Performance Optimization

### Caching Dependencies
```yaml
- name: Cache Node modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### Parallel Jobs
Multiple independent jobs run in parallel:
- Salesforce validation
- Vlocity validation  
- Code quality scan
- Dependency check

### Conditional Execution
Jobs only run if:
- Delta detection shows changes
- Previous stage succeeded
- Branch conditions met

---

## Security Best Practices

1. **Secret Management**
   - Never commit secrets
   - Rotate secrets regularly
   - Use environment-specific secrets
   - Limit secret scope

2. **Access Control**
   - Require branch protection
   - Mandate PR reviews
   - Environment approvals
   - Audit logs

3. **Code Security**
   - Scan for hardcoded credentials
   - Dependency vulnerability check
   - SAST scanning
   - Secret scanning

4. **Audit Trail**
   - Preserve deployment logs
   - Archive artifacts
   - Track all changes
   - Monitor access

---

## Support & Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Salesforce CLI Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [Vlocity Documentation](https://docs.vlocity.com/)
- [sfdx-project.json Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev_guide.meta/sfdx_dev_guide/sfdx_project_config.htm)
