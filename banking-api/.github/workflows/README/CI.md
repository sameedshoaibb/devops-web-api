# Continuous Integration Pipeline

## Overview

The CI pipeline runs automatically on every push to the `dev` branch. It performs:
- Code quality validation
- Unit testing
- Comprehensive security scans
- Dependency vulnerability checks

**Pipeline Trigger:** Push to `dev` branch

---

## Pipeline Stages

### Stage 1: Checkout
Downloads the latest code from the repository.

### Stage 2: Setup Environment
Installs required tools:
- Node.js v20
- pnpm v9.14.4

### Stage 3: Install Dependencies
Installs exact package versions from `pnpm-lock.yaml` for reproducible builds.

### Stage 4: Run Unit Tests
Executes all unit tests and generates JSON results for reporting.

### Stage 5: Build & Compile
Compiles TypeScript to JavaScript.

### Stage 6: Dependency Scan
Scans dependencies for known vulnerabilities using security databases.

### Stage 7: File System Scan
Scans source code using Trivy to identify security issues in the codebase.

### Stage 8: Upload Reports
Uploads all scan results and test reports as artifacts for review.

### Stage 9: Code Quality Analysis
Analyzes code with SonarQube for:
- Code coverage metrics
- Code smells detection
- Complexity analysis
- Best practice violations

---

## Key Features

- **Security First** - Multiple scanning stages for dependencies and source code
- **Reproducible Builds** - Uses locked dependency versions
- **Comprehensive Reporting** - All results uploaded as artifacts
- **Early Feedback** - Immediate notification on push to `dev`

---