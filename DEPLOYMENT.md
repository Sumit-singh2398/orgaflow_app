# OrgaFlow Deployment Guide

Ye guide step-by-step deployment batati hai: **Backend (Render + Neon)** aur
**Flutter app (Android)**.

---

## 1) BACKEND — Render + Neon

### Step 1: Codes ko GitHub pe push karo
```powershell
git add .
git commit -m "OrgaFlow: Neon-ready backend + clean Flutter app"
# GitHub par new repo banao (e.g. orgaflow), phir:
git remote add origin https://github.com/<tumhara-username>/orgaflow.git
git push -u origin main
```

### Step 2: Neon Postgres setup
1. https://console.neon.tech → Project Dashboard → **"Connect"** button
2. **Pooled connection string** copy karo (`...-pooler...aws.neon.tech/dbname?sslmode=require`)
3. Render dashboard ke **Environment** section mein `DATABASE_URL` naam se paste karo

### Step 3: Render Blueprint se deploy
- Repo root mein `render.yaml` hai (Blueprint ready)
- Render → **New +** → **Blueprint** → apna repo select karo
- Auto-config: Python runtime, `pip install`, `uvicorn` start, health check `/api/health`
- DB Schema/tables **startup pe auto-create** ho jaati (Notifications, OAuth tables, Request tracking)
- Free plan pe **cold start** slow ho sakta hai (Pehli request ~30s)

### Step 4: Verify
- `GET /api/health` → 200 aana chahiye (Database connection OK)
- App ka `baseUrl` ye hai: `https://orgaflow-app.onrender.com`

---

## 2) FLUTTER APP — Android Release

### Option A: Direct APK install (testing / personal use)
```powershell
flutter build apk --release
# APK: build\app\outputs\flutter-apk\app-release.apk
```
Debug-signed hai apna personal use ke liye kaafi hai.

### Option B: Play Store upload (public launch)
Pehle ye 2 karna hoga (abhi baad ke liye chhoda hai):

1. **Release keystore generate karo:**
```powershell
keytool -genkey -v -keystore %USERPROFILE%\orgaflow-release-key.jks `
  -keyalg RSA -keysize 2048 -validity 10000 -alias orgaflow
```
2. **`android/key.properties` file banao:**
```
storePassword=<tumhara-password>
keyPassword=<tumhara-password>
keyAlias=orgaflow
storeFile=C:/Users/singh/orgaflow-release-key.jks
```
3. `android/app/build.gradle.kts` mein signing config set karo + `.gitignore` mein
   `key.properties` aur `*.jks` add karo.
4. Play Console → AAB upload:
```powershell
flutter build appbundle --release
```

> Note: `applicationId = com.example.orgaflow_app` abhi default hai (tumne
> rehne ko bola). Play Store major warnings de sakta hai; `_example` public
> apps mein discourage kiya jaata hai.

---

## 3) ENVIRONMENT VARIABLES — Kya kaha set karna hai?

| Variable | Local (`orgaflow_backend/.env`) | Render Dashboard |
|---|---|---|
| `DATABASE_URL` | ✅ Neon pooled string | ✅ Neon pooled string |
| `ORGAFLOW_JWT_SECRET` | ✅ random 64+ chars | ✅ Render auto-generate ho jayega |
| `GOOGLE_CLIENT_ID` | optional (default है) | optional |

`.env` file **git mein kabhi commit na karo** — `.gitignore` already handles this.

---

## 4) DEPLOY CHECKLIST

- [ ] Code GitHub pe push ho gaya
- [ ] Neon project ready + pooled connection string
- [ ] Render Blueprint deploy → `/api/health` 200
- [ ] Flutter app release APK built & phone pe installed
- [ ] Login/Signup backend se kaam kar raha
- [ ] Google Sign-In Android device pe chala
- [ ] Asset requests create/approve/reject chal raha
- [ ] Notifications api chal rahi
