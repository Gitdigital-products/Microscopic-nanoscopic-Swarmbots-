#!/bin/bash

ORG="Gitdigital-products"
TOKEN="YOUR_GITHUB_TOKEN_HERE"

# Temp working directory
WORKDIR="./gitdigital_repos"
mkdir -p $WORKDIR
cd $WORKDIR

echo "🔍 Fetching repository list for $ORG..."

REPOS=$(curl -s -H "Authorization: token $TOKEN" \
  "https://api.github.com/orgs/$ORG/repos?per_page=200" | jq -r '.[].name')

for REPO in $REPOS; do
    echo "📦 Processing repo: $REPO"

    if [ -d "$REPO" ]; then
        rm -rf "$REPO"
    fi

    git clone "https://github.com/$ORG/$REPO.git"
    cd "$REPO"

    echo "📁 Creating .github folders..."
    mkdir -p .github
    mkdir -p .github/ISSUE_TEMPLATE
    mkdir -p .github/workflows

    echo "📝 Adding Pull Request Template..."
    cat > .github/pull_request_template.md << 'EOF'
## Summary
Describe the changes you made and why they matter.

## Type of Change
- [ ] Feature
- [ ] Bug Fix
- [ ] Refactor
- [ ] Documentation
- [ ] Other

## What Was Changed?
Explain what files or modules were impacted.

## How To Test
Steps to manually test this PR.

## Checklist
- [ ] Code builds without errors
- [ ] Code follows project style
- [ ] Tests pass (if applicable)
- [ ] No breaking changes introduced
EOF

    echo "📝 Adding Issue Template..."
    cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug Report
about: Report a bug to help us improve
title: "[BUG]"
labels: bug
---

## Bug Description
Describe the issue clearly.

## Steps To Reproduce
1.
2.
3.

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Logs / Screenshots
(Add here)

## Environment
- OS:
- Branch:
- Repo:
EOF

    echo "⚙ Adding Enforce Quality GitHub Action..."
    cat > .github/workflows/enforce-quality.yml << 'EOF'
name: Enforce Quality

on:
  pull_request:
  push:
    branches:
      - main
      - master

jobs:
  lint-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.x'

      - name: Install Tools
        run: |
          pip install flake8 black

      - name: Run Black
        run: black --check .

      - name: Run Flake8
        run: flake8 --ignore=E501
EOF

    echo "📚 Adding README.md if missing..."
    if [ ! -f README.md ]; then
        cat > README.md << 'EOF'
# GitDigital — Microservice

This service is part of the GitDigital Products PaaS ecosystem.

## Development Setup
