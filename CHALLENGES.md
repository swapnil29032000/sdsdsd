# 🚧 Challenges & Solutions

This document highlights the major technical hurdles encountered during the dockerization of the Nexgensis DevOps Assessment project and how they were resolved to meet production standards.

---

## 1. Final Node-Based Implementation (No Nginx)
### **The Problem**
The setup initially encountered two critical failures:
1.  **Syntax Error**: `adduser: Specify only one name in this mode` (due to Debian-specific `adduser` behavior).
2.  **Permission Error**: `EACCES: mkdir '/nonexistent'` (due to `npm/npx` trying to download packages at runtime into a non-writable or missing home directory).

### **The Solution**
- **Robust User Creation**: Switched to `useradd -m nodejs`, which is the correct low-level tool for Debian (`node-slim`) images to ensure a valid home directory is created.
- **Global Installation**: Avoided runtime downloads by installing the `serve` package globally *inside* the image during the build phase as root.
- **Home Environment**: Explicitly set `ENV HOME=/home/nodejs` to give the non-root user a reliable writable space for internal Node/npm caches.

---

## 2. Multi-Stage Build & Permission Denied Errors
### **The Problem**
Running as a **non-root user** often leads to `Permission Denied` errors when the runtime user doesn't own the files copied from the build stage.
### **The Solution**
We implemented precise ownership changes in the Dockerfiles using `chown` immediately before switching to the non-root user.

---

## 3. Backend Dependency Ghosting
### **The Problem**
The provided backend was missing a `requirements.txt` file, making builds non-reproducible.
### **The Solution**
We analyzed `settings.py` to identify required packages like `django-cors-headers` and `python-dotenv`, then generated a pinned `requirements.txt`.

---

## 4. Environment Discovery
### **The Problem**
Browsers expect the API at `localhost:8000`, but Docker services often resolve internally.
### **The Solution**
We mapped the environment variable `VITE_API_URL` to `http://localhost:8000/api` to ensure seamless local developer experience while remaining configurable for other environments.
