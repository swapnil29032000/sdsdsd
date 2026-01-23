# 🚧 Challenges & Solutions

This document highlights the major technical hurdles encountered during the dockerization of the Nexgensis DevOps Assessment project.

---

## 1. Final Node-Based Implementation (No Nginx)
### **The Problem**
Initial attempts failed due to:
1.  **Syntax Error**: `adduser` behavior inconsistencies in `node:slim`.
2.  **Permission Error**: `EACCES: mkdir '/nonexistent'` when `npx` tried to download packages at runtime.

### **The Solution**
- Used `useradd -m nodejs` for correct home directory creation.
- Pre-installed `serve` globally in the image to eliminate runtime downloads.
- Set `ENV HOME=/home/nodejs` to provide a writable cache space.

---

## 2. Dynamic CI/CD Branch Mapping
### **The Problem**
Teammates need automated deployments across multiple environments (`DEV`, `QA`, `PROD`).
### **The Solution**
Used a `case` statement in GitHub Actions to dynamically tag images (e.g., `prod-latest`, `qa-latest`) based on the active branch, enabling a single workflow to handle all deployment tiers.

---

## 3. Multi-Stage Build & Permission Denied Errors
### **The Problem**
Non-root users often cannot access files copied from the root-owned build stage.
### **The Solution**
Implemented `chown -R nodejs:nodejs /app` immediately after copying artifacts to the final stage.

---

## 4. Backend Dependency Management
### **The Problem**
Missing `requirements.txt` lead to non-reproducible builds.
### **The Solution**
Generated a pinned `requirements.txt` by analyzing the project imports and settings.
