# 🚀 Orgaflow

### Smart Organization Asset Management Platform

**Orgaflow** is a full-stack organization asset management platform designed to help companies manage employees, organizational assets, asset requests, approvals, maintenance, and role-based access from a single system.

The platform provides separate experiences for **Employees, Asset Managers, Department Heads, and Administrators**, with a Flutter mobile frontend and a FastAPI + PostgreSQL backend.

---

## 📌 Project Overview

Organizations often manage laptops, smartphones, cameras, projectors, networking devices, UPS systems, displays, and other equipment using spreadsheets or disconnected systems.

Orgaflow aims to solve this problem by providing a centralized digital asset management platform where:

* Employees can view available and assigned assets.
* Employees can submit asset requests.
* Employees can track their requests.
* Asset Managers can review and process employee requests.
* Managers can approve or reject requests.
* Rejection requires a proper reason.
* Request status is stored permanently in PostgreSQL.
* Role-based authorization protects management functionality.
* Authentication is handled using JWT and Google OAuth.
* Backend APIs provide communication between the Flutter application and PostgreSQL database.

---

# 🎯 MVP

The current MVP focuses on the complete employee asset-request workflow.

### MVP Flow

```text
Employee Login
      ↓
Employee Dashboard
      ↓
Available Assets
      ↓
Select Asset
      ↓
Submit Asset Request
      ↓
FastAPI Backend
      ↓
PostgreSQL Database
      ↓
Asset Manager Dashboard
      ↓
Review Request
      ↓
 ┌───────────────┐
 │               │
Approve       Not Approve
 │               │
 ↓               ↓
Approved     Rejection Reason
 │               │
 └───────┬───────┘
         ↓
 PostgreSQL
         ↓
Employee Track Requests
```

---

# ✨ Core Features

## 👨‍💻 Employee Portal

Employees can:

* Register and log in.
* Login using Google.
* View their dashboard.
* Browse available assets.
* View asset information.
* Submit asset requests.
* Select request priority.
* Add a request description.
* Track submitted requests.
* View request status.
* View approval status.
* View rejection reason when a request is not approved.
* View their profile.

### Employee Request Status

```text
Pending
   ↓
 ┌───────────────┐
 ↓               ↓
Approved     Not Approved
                 ↓
          Rejection Reason
```

Employees can only access their own requests.

They cannot approve or reject requests.

---

# 🧑‍💼 Asset Manager Portal

Asset Managers can:

* View employee asset requests.
* View employee information.
* View department.
* View requested asset.
* View asset category.
* View brand and model.
* View priority.
* View employee description.
* View request creation date.
* Approve pending requests.
* Reject pending requests.
* Provide a rejection reason.
* Track request status.
* Refresh data directly from the backend.

### Request Management

A pending request can be processed as:

```text
Pending
   │
   ├── Approve
   │      ↓
   │   Approved
   │
   └── Not Approve
          ↓
   Rejection Reason
          ↓
      Not Approved
```

---

# 🔐 Role-Based Access Control

Orgaflow is designed around role-based authorization.

### Supported Roles

| Role            | Access                           |
| --------------- | -------------------------------- |
| Employee        | Employee portal                  |
| Asset Manager   | Asset/request management         |
| Department Head | Management portal                |
| Admin           | Administrative/management access |

The selected portal and role are validated by the backend.

Users cannot simply select a privileged role from the UI and gain management access.

The backend validates the authenticated user's actual database role before allowing protected operations.

---

# 🔑 Authentication

Orgaflow supports:

### Email & Password

```text
Email
Password
   ↓
FastAPI
   ↓
Password Verification
   ↓
JWT Token
   ↓
Authenticated Session
```

Passwords are stored as hashes rather than plain text.

### Google Authentication

Google OAuth is also integrated for supported login flows.

The backend verifies the Google identity token before creating/authenticating the user.

---

# 🏗️ System Architecture

```text
┌─────────────────────────────┐
│        Flutter App          │
│                             │
│  Employee Portal            │
│  Asset Manager Portal       │
│  Authentication             │
│  Request Management         │
└──────────────┬──────────────┘
               │
               │ REST API
               ▼
┌─────────────────────────────┐
│        FastAPI Backend      │
│                             │
│ Authentication              │
│ JWT Authorization            │
│ Role Validation             │
│ Asset Requests              │
│ Request Approval             │
│ Request Tracking             │
└──────────────┬──────────────┘
               │
               │ SQL
               ▼
┌─────────────────────────────┐
│        PostgreSQL           │
│                             │
│ users                       │
│ oauth_users                 │
│ asset_requests              │
│ departments                 │
│ assets / related data       │
└─────────────────────────────┘
```

---

# 🛠️ Tech Stack

## Frontend

* Flutter
* Dart
* Material UI
* GetX
* HTTP REST API
* SharedPreferences

## Backend

* Python
* FastAPI
* JWT
* Passlib / bcrypt
* Google OAuth verification
* REST APIs

## Database

* PostgreSQL

## Development Tools

* Android Studio
* VS Code
* Git
* GitHub
* Docker

## Deployment

Backend deployment is planned for a cloud environment such as Render.

---

# 🗄️ Database

The backend uses PostgreSQL with the database:

```text
orgaflow_db
```

### Users

The users table stores authentication and authorization information.

Example fields:

```text
id
name
email
password_hash
role
department_id
status
created_at
```

### OAuth Users

Google authentication mappings are stored separately.

Example fields:

```text
user_id
google_id
email
name
portal
role
status
```

### Asset Requests

The asset request system stores complete request information.

Example fields:

```text
id
request_code
user_id
employee_name
employee_email
department
asset_id
asset_name
asset_category
asset_brand
asset_model
priority
description
status
rejection_reason
created_at
updated_at
reviewed_at
reviewed_by
```

---

# 🔄 Real-Time Request Workflow

When an employee submits a request, the Flutter application sends the request to the FastAPI backend.

Example:

```http
POST /api/requests
```

The backend:

1. Authenticates the employee.
2. Validates the JWT token.
3. Gets the employee from PostgreSQL.
4. Validates the request data.
5. Creates a unique request code.
6. Stores the request in PostgreSQL.
7. Returns the created request.

The Flutter app only displays success when the backend successfully creates the request.

---

# 📡 API Endpoints

## Authentication

```http
POST /api/auth/signup
POST /api/auth/login
POST /api/auth/google-login
```

## Requests

### Create Request

```http
POST /api/requests
```

### Get All Requests

```http
GET /api/requests
```

Management users can use this endpoint to review requests.

### Get Current Employee Requests

```http
GET /api/requests/my
```

Employees receive only their own requests.

### Get Request Details

```http
GET /api/requests/{request_id}
```

### Update Request Status

```http
PATCH /api/requests/{request_id}/status
```

Example approval:

```json
{
  "status": "Approved",
  "rejection_reason": null
}
```

Example rejection:

```json
{
  "status": "Rejected",
  "rejection_reason": "Asset is currently unavailable."
}
```

### Request Statistics

```http
GET /api/requests/stats
```

---

# 🛡️ Backend Security

The backend is responsible for authorization instead of trusting the Flutter UI.

Security mechanisms include:

* JWT authentication
* Password hashing
* Active user validation
* Role-based authorization
* Protected management endpoints
* Employee-specific request filtering
* Request status validation
* Rejection reason validation
* Database persistence
* Google identity-token verification

For example, an employee cannot simply send:

```json
{
  "role": "ADMIN"
}
```

and gain administrator permissions.

The backend checks the user's actual role stored in the database.

---

# 📱 Application Screens

## Employee

```text
Login
  ↓
Employee Home
  ↓
Available Assets
  ↓
Asset Details
  ↓
Request Asset
  ↓
Track Requests
  ↓
Profile
```

## Asset Manager

```text
Management Login
       ↓
Asset Manager Dashboard
       ↓
Asset Requests
       ↓
Request Details
       ↓
Approve / Not Approve
       ↓
Request History
```

---

# 📦 Example Assets

The application can manage different organizational assets such as:

* Dell Latitude 5420
* Samsung Galaxy A55
* DSLR Camera
* Tripod
* Projector
* Conference Room Display
* UPS
* Wi-Fi Router

Assets contain information such as:

```text
Asset Name
Asset ID
Category
Brand
Model
Status
Image
```

---

# 📂 Project Structure

```text
orgaflow_app/
│
├── lib/
│   │
│   ├── employee/
│   │   ├── existing_employee_home.dart
│   │   ├── employee_assets_page.dart
│   │   ├── employee_my_assets_page.dart
│   │   ├── employee_track_requests_page.dart
│   │   ├── employee_profile_page.dart
│   │   └── my_request.dart
│   │
│   ├── asset_manager/
│   │   ├── asset_manager_dashboard.dart
│   │   ├── asset_manager_request.dart
│   │   ├── asset_manager_maintenance.dart
│   │   └── asset_manager_history.dart
│   │
│   ├── auth/
│   │   └── login_screen.dart
│   │
│   └── main.dart
│
├── orgaflow_backend/
│   ├── main.py
│   └── ...
│
├── android/
├── assets/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

---

# 🚀 Running the Project Locally

## 1. Clone Repository

```bash
git clone https://github.com/Sumit-singh2398/orgaflow_app.git
```

```bash
cd orgaflow_app
```

---

# 2. Flutter Setup

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# 3. PostgreSQL Setup

Create the PostgreSQL database:

```text
orgaflow_db
```

Configure the database connection in the FastAPI backend.

Example:

```text
Host: localhost
Port: 5432
Database: orgaflow_db
User: postgres
```

---

# 4. Start FastAPI Backend

Navigate to:

```bash
cd orgaflow_backend
```

Run:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Backend:

```text
http://127.0.0.1:8000
```

Swagger API documentation:

```text
http://127.0.0.1:8000/docs
```

---

# 📱 Android Emulator

For an Android emulator, the Flutter application can communicate with the local backend using:

```text
http://10.0.2.2:8000
```

For a physical Android device, use the computer's local IPv4 address:

```text
http://YOUR_PC_IP:8000
```

The FastAPI server should be started with:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

---

# 🐳 Docker

Docker is part of the project development/deployment workflow.

The planned architecture is:

```text
Flutter Application
       │
       ▼
FastAPI Container
       │
       ▼
PostgreSQL
```

This makes the backend easier to reproduce and deploy across environments.

---

# 📊 MVP Status

| Feature                   | Status |
| ------------------------- | ------ |
| Flutter Application       | ✅      |
| Employee Portal           | ✅      |
| Authentication            | ✅      |
| JWT Authentication        | ✅      |
| Password Hashing          | ✅      |
| Google OAuth              | ✅      |
| PostgreSQL                | ✅      |
| FastAPI Backend           | ✅      |
| Employee Asset Requests   | ✅      |
| Request Persistence       | ✅      |
| Employee Request Tracking | ✅      |
| Asset Manager Requests    | ✅      |
| Approve Request           | ✅      |
| Reject Request            | ✅      |
| Rejection Reason          | ✅      |
| Role-Based Authorization  | ✅      |
| Docker Workflow           | 🚧     |
| Cloud Deployment          | 🚧     |
| Advanced Asset Inventory  | 🚧     |
| Maintenance Management    | 🚧     |
| Analytics Dashboard       | 🚧     |

---

# 🔮 Future Scope

Orgaflow can be extended with:

### Asset Inventory

* Add new assets
* Edit asset information
* Assign assets
* Transfer assets
* Return assets
* Retire assets
* Asset lifecycle tracking

### Maintenance

* Maintenance scheduling
* Maintenance history
* Repair requests
* Service provider records
* Maintenance cost tracking

### Notifications

* Push notifications
* Email notifications
* Request approval notifications
* Asset assignment notifications
* Maintenance reminders

### Analytics

* Total assets
* Available assets
* Assigned assets
* Pending requests
* Approved requests
* Rejected requests
* Maintenance costs
* Department-wise asset usage

### Advanced Security

* Refresh tokens
* Audit logs
* Permission-based authorization
* Session management
* Login activity
* Security monitoring

---

# 🎯 Project Goals

Orgaflow is being developed with the following goals:

* Reduce manual asset management.
* Centralize organizational assets.
* Improve request processing.
* Provide transparent request tracking.
* Reduce dependency on spreadsheets.
* Provide secure role-based access.
* Maintain reliable database records.
* Create a scalable asset management platform.

---

# 💡 Why Orgaflow?

Traditional asset management can involve:

```text
Excel Sheets
     +
Emails
     +
WhatsApp Messages
     +
Manual Approval
     +
Separate Records
```

Orgaflow brings these workflows together:

```text
             ORGAFLOW
                │
     ┌──────────┼──────────┐
     │          │          │
 Employees   Managers    Admin
     │          │          │
     └──────────┼──────────┘
                │
          Asset Database
                │
          Request System
                │
        Approval Workflow
```

---

# 🧪 Development Approach

The project follows a full-stack development approach:

```text
Flutter UI
    ↓
REST API
    ↓
Authentication
    ↓
Authorization
    ↓
Business Logic
    ↓
PostgreSQL
```

The frontend is responsible for the user experience while the backend handles authentication, authorization, validation, business logic, and persistent data.

---

# 👨‍💻 Developer

**Sumit Singh**

BCA Student | Flutter Developer | Full-Stack Developer

### Skills Used

```text
Flutter
Dart
Python
FastAPI
PostgreSQL
Firebase
REST APIs
JWT
Google OAuth
Git
GitHub
Docker
```

---

# 📌 Project

**Project Name:** Orgaflow

**Category:** Asset Management / Organization Management

**Type:** Full-Stack Application

**Frontend:** Flutter

**Backend:** FastAPI

**Database:** PostgreSQL

**Authentication:** JWT + Google OAuth

**Repository:** `orgaflow_app`

---

# ⭐ Contributing

This project is currently under active development.

Suggestions, improvements, and feature ideas are welcome.

If you find an issue, please open an issue in the repository.

---

# 📄 License

This project is currently being developed as a student/portfolio project.

License information can be added when the project is released publicly.

---

## 🚀 Orgaflow

**Manage Assets. Simplify Requests. Empower Organizations.**
