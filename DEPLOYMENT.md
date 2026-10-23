# OrgaFlow Deployment Guide

Ye guide step-by-step deployment batati hai: **Backend (Render + Neon)** aur
**Flutter app (Android)**.

---

## 1) BACKEND — Render + Neon

### Step 1: Codes ko GitHub pe push karo
```powershell
git add .
git commit -m "Deploy fix: centralized AppConfig, clean render.yaml without BOM, Neon pooled DSN support"
git push origin main
```

### Step 2: Neon Postgres setup
1. https://console.neon.tech → Project Dashboard → **"Connect"** button
2. **Pooled connection string** copy karo (`...-pooler...aws.neon.tech/neondb?sslmode=require`)
   *(Note: Pooled connection me `channel_binding` use na karein, backend ise auto-strip bhi kar deta hai)*
3. Render dashboard ke **Environment** section mein `DATABASE_URL` naam se paste karo

### Step 3: Render Blueprint se deploy
- Repo root mein `render.yaml` hai (Blueprint ready, UTF-8 clean without BOM)
- Render → **New +** → **Blueprint** → apna repo select karo
- Service ka default naam `orgaflow-backend` hai
- Auto-config: Python runtime, `pip install`, `uvicorn` start, health check `/api/health`
- DB Schema/tables **startup pe auto-create** ho jaati (Notifications, OAuth tables, Request tracking)
- Free plan pe **cold start** slow ho sakta hai (Pehli request ~30s)

### Step 4: Verify & App URL Update
- Render dashboard par jo URL generate ho (e.g. `https://orgaflow-backend.onrender.com` ya `https://orgaflow-app.onrender.com`):
- `GET /api/health` browser me open karo → 200 `{ "success": true, "message": "Backend and database are connected." }` aana chahiye.
- Ab Flutter app ke single file me Render URL daal do:
  **`lib/config/api_config.dart`** → `static const String baseUrl = 'https://<tumhara-service-url>.onrender.com';`

---

## 2) FLUTTER APP — Android Release

### Option A: Direct APK install (testing / personal use)
```powershell
cd orgaflow_app
flutter build apk --release
# APK output: build\app\outputs\flutter-apk\app-release.apk
```
Debug-signed hai apna personal use ke liye kaafi hai.

### Option B: Play Store upload (public launch)
Pehle ye setup karo:

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

---

## 3) ENVIRONMENT VARIABLES — Kya kaha set karna hai?

| Variable | Local (`orgaflow_backend/.env`) | Render Dashboard |
|---|---|---|
| `DATABASE_URL` | ✅ Neon pooled string | ✅ Neon pooled string |
| `ORGAFLOW_JWT_SECRET` | ✅ random 64+ chars | ✅ Render auto-generate / custom |
| `GOOGLE_CLIENT_ID` | optional (default set) | optional |

> **Security Note:** Render deploy ho jaane ke baad Neon Console me password rotate kar lena aur Render Dashboard me Environment variables ke through secure rakhna.

---

## 4) DEPLOY CHECKLIST

- [x] `render.yaml` UTF-8 BOM removed
- [x] Backend URL centralized in `lib/config/api_config.dart`
- [x] `employee_notification_service.dart` pointed to `AppConfig.baseUrl` (no longer stuck on `127.0.0.1`)
- [ ] Code GitHub pe push ho gaya
- [ ] Neon project ready + pooled connection string
- [ ] Render Blueprint deploy → `/api/health` 200
- [ ] Flutter app release APK built & phone pe installed
- [ ] Login/Signup backend se kaam kar raha
- [ ] Google Sign-In Android device pe chala
- [ ] Asset requests create/approve/reject chal raha
- [ ] Notifications api chal rahi
