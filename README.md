# Orgaflow — Enterprise Asset & Resource Management

<div align="center">

  <!-- Replace this path with your actual Orgaflow app logo path -->
  <img src="assets/images/orgaflow_logo.png" alt="Orgaflow Logo" width="180"/>

  <h1>ORGAFLOW</h1>

  ### Manage Assets. Automate Requests. Empower Organizations.

  A full-stack asset management platform built to simplify asset inventory, employee requests, approvals, assignments, and organizational resource tracking.

  <p>
    <img src="https://img.shields.io/badge/Flutter-3.35.3-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
    <img src="https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart&logoColor=white" alt="Dart"/>
    <img src="https://img.shields.io/badge/FastAPI-Python-009688?logo=fastapi&logoColor=white" alt="FastAPI"/>
    <img src="https://img.shields.io/badge/PostgreSQL-Database-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL"/>
    <img src="https://img.shields.io/badge/Auth-JWT-black?logo=jsonwebtokens&logoColor=white" alt="JWT"/>
  </p>

  <p>
    <img src="https://img.shields.io/badge/Google-OAuth-4285F4?logo=google&logoColor=white" alt="Google OAuth"/>
    <img src="https://img.shields.io/badge/Docker-Containerization-2496ED?logo=docker&logoColor=white" alt="Docker"/>
    <img src="https://img.shields.io/badge/State%20Management-GetX-purple" alt="GetX"/>
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Web-3B5BDB" alt="Platforms"/>
    <img src="https://img.shields.io/badge/Status-Active%20Development-success" alt="Development Status"/>
  </p>

  <p>
    <a href="#-overview">Overview</a> •
    <a href="#-features">Features</a> •
    <a href="#-architecture">Architecture</a> •
    <a href="#-technology-stack">Tech Stack</a> •
    <a href="#-roadmap">Roadmap</a>
  </p>

</div>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Problem Statement](#-problem-statement)
- [Project Objectives](#-project-objectives)
- [Key Features](#-features)
- [User Roles](#-user-roles)
- [Employee Portal](#-employee-portal)
- [Asset Manager Portal](#-asset-manager-portal)
- [Department Head Portal](#-department-head-portal)
- [Admin Portal](#-admin-portal)
- [Asset Lifecycle](#-asset-lifecycle)
- [Request Management](#-request-management)
- [Authentication and Security](#-authentication-and-security)
- [System Architecture](#-architecture)
- [Database Design](#-database-design)
- [REST API](#-rest-api)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Environment Configuration](#-environment-configuration)
- [Development Status](#-development-status)
- [Roadmap](#-roadmap)
- [Future Enhancements](#-future-enhancements)
- [Contributing](#-contributing)
- [Developer](#-developer)
- [License](#-license)

---

## 🌐 Overview

**Orgaflow** is a full-stack Enterprise Asset & Resource Management Platform designed to centralize organizational assets and streamline employee resource requests.

Organizations use different types of equipment, including laptops, smartphones, cameras, projectors, networking equipment, and other office resources. Managing these assets through spreadsheets, emails, and disconnected records can make tracking, approvals, and accountability difficult.

Orgaflow aims to bring these operations together in one application using a Flutter frontend, FastAPI backend, and PostgreSQL database.

### 🎯 Vision

To create a centralized platform where organizations can manage assets, employees, departments, requests, approvals, and asset operations through structured digital workflows.

### 💡 Core Concept

```text
                 ORGAFLOW
                    |
        +-----------+-----------+
        |           |           |
     Employee   Management     Admin
        |           |           |
        +-----------+-----------+
                    |
            Asset Inventory
                    |
            Employee Requests
                    |
            Approval Workflow
                    |
            Asset Assignment
                    |
         Maintenance & Tracking
                    |
           Reports & Analytics
```

---

## ❗ Problem Statement

Traditional asset management processes may involve:

- Manually maintained spreadsheets.
- Disconnected employee and asset records.
- Delayed approval workflows.
- Difficulty tracking asset availability.
- Limited visibility into request status.
- Inconsistent maintenance records.
- Poor accountability for asset assignments.

### ✅ Proposed Solution

Orgaflow provides a unified system for:

- Maintaining asset information.
- Allowing employees to request resources.
- Enabling authorized managers to review requests.
- Tracking request status and rejection reasons.
- Supporting role-specific management interfaces.
- Building a foundation for asset assignment, maintenance, and analytics.

---

## ✨ Features

### 🔐 Authentication

- Email and password authentication.
- Password hashing on the backend.
- JWT-based authentication.
- Google Sign-In integration.
- Active-account validation.
- Role-aware portal access.
- Protected backend endpoints.

### 📦 Asset Management

- Asset inventory interface.
- Asset identification and categories.
- Brand and model information.
- Asset availability and status.
- Asset details and location information.
- Foundation for asset assignment and lifecycle tracking.

### 📝 Request Management

- Employee asset requests.
- Request priority selection.
- Request descriptions.
- Unique request codes.
- Request status tracking.
- Manager approval and rejection.
- Rejection reason support.
- Persistent request records in PostgreSQL.

### 👥 User and Department Management

- Employee profiles.
- Role-based access.
- Department association.
- Department-specific interfaces.
- Management-oriented dashboards.

### 📊 Reporting and Analytics

Planned reporting capabilities include:

- Total and available assets.
- Assigned and under-maintenance assets.
- Pending and processed requests.
- Department-wise asset distribution.
- Maintenance statistics.
- Exportable management reports.

---

## 👤 User Roles

Orgaflow is designed around Role-Based Access Control (RBAC).

| Role | Responsibilities |
|---|---|
| Employee | Browse assets, submit requests, track requests, and view assigned resources |
| Asset Manager | Review requests, manage asset operations, and monitor request history |
| Department Head | Oversee department employees, assets, and departmental requirements |
| Admin | Manage system-wide users, roles, departments, and configuration |

**Security principle:** The backend must validate the authenticated user's role and permissions. Hiding a button in Flutter is not sufficient authorization.

---

## 👨‍💻 Employee Portal

The Employee Portal provides a dedicated interface for employees.

### Capabilities

- Register and log in.
- Sign in using Google.
- Browse available assets.
- View asset details.
- Submit asset requests.
- Select request priority.
- Add request descriptions.
- Track submitted requests.
- View request status and rejection reasons.
- View assigned assets.
- Manage profile information.

### Employee Navigation

```text
+-----------------------------+
|       Employee Home         |
+-----------------------------+
|                             |
|  Home                       |
|  Assets                     |
|  My Requests                |
|  My Assets                  |
|  Profile                    |
|                             |
+-----------------------------+
```

---

## 🧑‍💼 Asset Manager Portal

The Asset Manager Portal focuses on operational asset and request management.

### Request Management

- View employee requests.
- Search and filter requests.
- Review employee and department information.
- View asset details, priority, and description.
- Approve pending requests.
- Reject requests with a reason.
- Review request history.
- Monitor request statistics.

### Request Review Workflow

```text
           Pending Request
                  |
          +-------+-------+
          |               |
       Approve          Reject
          |               |
          v               v
       Approved     Reason Required
                          |
                          v
                       Rejected
```

### Future Asset Operations

The platform can be extended to support:

- Creating and editing assets.
- Assigning assets to employees.
- Recording asset returns.
- Transferring assets between departments.
- Tracking warranties and serial numbers.
- Managing maintenance tickets.
- Generating asset reports.

---

## 🏢 Department Head Portal

The Department Head Portal is designed for department-level oversight.

Potential capabilities include:

- View department employees.
- View department assets.
- Review departmental requests.
- Monitor asset availability.
- Track department-level requirements.
- Review departmental reports.

Department Heads should only access information within their authorized department scope.

---

## 👑 Admin Portal

The Admin Portal is intended for organization-wide administration.

Planned responsibilities include:

- User and account management.
- Role and permission management.
- Department management.
- Asset oversight.
- Request oversight.
- System configuration.
- Audit logs.
- Organization-wide analytics.

Administrative actions must be authorized and validated by the backend.

---

## 🔄 Asset Lifecycle

Orgaflow is designed to support the lifecycle of organizational assets.

```text
Asset Registration
        |
        v
    Available
        |
        v
  Employee Request
        |
        v
  Manager Review
        |
        +------------------+
        |                  |
        v                  v
    Approved            Rejected
        |
        v
 Asset Assignment
        |
        v
      In Use
        |
        v
 Return / Maintenance
        |
        v
    Available
        |
        v
     Retired
```

The complete lifecycle depends on implementing and connecting the corresponding backend operations.

---

## 📝 Request Management

Each asset request is associated with structured employee, asset, and review information.

### Employee Information

- User ID.
- Employee name.
- Employee email.
- Department.

### Asset Information

- Asset ID.
- Asset name.
- Category.
- Brand.
- Model.

### Request Information

- Unique request code.
- Priority.
- Description.
- Current status.
- Creation and update timestamps.
- Reviewer information.
- Review timestamp.
- Rejection reason.

### Example Request

```json
{
  "asset_id": "AST-1001",
  "asset_name": "Dell Latitude 5420",
  "asset_category": "Laptop",
  "asset_brand": "Dell",
  "asset_model": "Latitude 5420",
  "department": "IT",
  "priority": "Normal",
  "description": "Laptop required for development work."
}
```

*This is an illustrative payload. The exact fields accepted by the API depend on the backend implementation.*

### Request Statuses

| Status | Meaning |
|---|---|
| Pending | Awaiting review |
| Approved | Request approved |
| Rejected | Request declined with a reason |

---

## 🔐 Authentication and Security

Orgaflow uses a backend-centered authentication and authorization architecture.

### Email and Password Authentication

```text
User Credentials
       |
       v
FastAPI Authentication
       |
       v
Password Verification
       |
       v
User and Account Validation
       |
       v
JWT Issuance
       |
       v
Authenticated Session
```

### Google OAuth

```text
Google Sign-In
       |
       v
Google Identity Token
       |
       v
FastAPI Token Verification
       |
       v
User Lookup and Role Validation
       |
       v
JWT Issuance
       |
       v
Authenticated Session
```

Google authentication does not automatically grant administrative privileges.

### Security Principles

- Store password hashes instead of plaintext passwords.
- Verify JWT signatures and expiration.
- Enforce role-based authorization on the backend.
- Validate input before database operations.
- Restrict users to their authorized records.
- Keep database credentials and signing secrets out of source control.
- Use HTTPS for deployed APIs.
- Configure CORS for trusted origins in production.
- Apply appropriate Google OAuth client configuration.
- Use database transactions for operations that modify related records.

> Security features should be considered production-ready only after implementation and testing.

---

## 🏗️ Architecture

Orgaflow separates the mobile application, backend API, database, and infrastructure layers.

```mermaid
flowchart TD
    U[User] --> F[Flutter Application]
    F --> UI[GetX State and Navigation]
    UI --> API[REST API Client]

    API --> AUTH[FastAPI Authentication]
    AUTH --> JWT[JWT Validation]
    JWT --> RBAC[Role Authorization]

    RBAC --> AS[Asset Management]
    RBAC --> REQ[Request Management]
    RBAC --> USERS[User Management]
    RBAC --> MAINT[Maintenance Operations]

    AS --> DB[(PostgreSQL)]
    REQ --> DB
    USERS --> DB
    MAINT --> DB

    BE[FastAPI Backend] -. Deployment .-> DOCKER[Docker]
    DOCKER -. Hosting .-> CLOUD[Cloud Platform]
```

### Frontend Responsibilities

- Render mobile-friendly interfaces.
- Handle navigation and forms.
- Validate user input.
- Communicate with the backend.
- Display loading, success, and error states.
- Present role-specific screens.

### Backend Responsibilities

- Authenticate users.
- Issue and validate tokens.
- Enforce permissions.
- Validate requests.
- Apply business rules.
- Read and update PostgreSQL records.
- Return structured API responses.

### Database Responsibilities

- Store user records.
- Maintain department associations.
- Persist asset requests.
- Support relationships between users, assets, and departments.
- Maintain reliable application records.

---

## 🗄️ Database Design

**Database:** PostgreSQL

**Database name:** `orgaflow_db`

The current backend uses relational storage for application data.

### Users

```text
users
├── id
├── name
├── email
├── password_hash
├── role
├── department_id
├── status
└── created_at
```

### Google OAuth Users

```text
oauth_users
├── user_id
├── google_id
├── email
├── name
├── portal
├── role
└── status
```

### Departments

```text
departments
├── id
├── name
├── head_id
├── status
└── created_at
```

### Assets — Target Structure

```text
assets
├── id
├── asset_code
├── name
├── category
├── brand
├── model
├── serial_number
├── status
├── department_id
├── assigned_user_id
├── location
├── purchase_date
├── warranty_end
├── image
├── created_at
└── updated_at
```

### Asset Requests

```text
asset_requests
├── id
├── request_code
├── user_id
├── employee_name
├── employee_email
├── department
├── asset_id
├── asset_name
├── asset_category
├── asset_brand
├── asset_model
├── priority
├── description
├── status
├── rejection_reason
├── created_at
├── updated_at
├── reviewed_at
└── reviewed_by
```

The asset, department, maintenance, and audit structures above describe the intended data model where those modules are not yet fully implemented. Actual column names and relationships should be verified against the database migrations and backend code.

---

## 🔗 REST API

Orgaflow uses REST APIs to connect the Flutter frontend with FastAPI.

### Authentication Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/auth/signup` | Register a user |
| POST | `/api/auth/login` | Authenticate using credentials |
| POST | `/api/auth/google-login` | Authenticate using Google |

### Request Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/requests` | Create an asset request |
| GET | `/api/requests` | Retrieve requests according to authorization |
| GET | `/api/requests/my` | Retrieve the authenticated user's requests |
| GET | `/api/requests/{request_id}` | Retrieve a specific request |
| PATCH | `/api/requests/{request_id}/status` | Update request status |
| GET | `/api/requests/stats` | Retrieve request statistics |

### System Endpoint

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/health` | Check backend health |

These endpoints reflect the project's API design and previously developed functionality. Confirm the exact routes, methods, and permissions in the current `main.py` before relying on this table as complete API documentation.

FastAPI interactive documentation is normally available at:

```text
http://localhost:8000/docs
```

---

## 🧰 Technology Stack

### Frontend

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application UI |
| Dart | Application programming language |
| Material UI | Interface components |
| GetX | State management and navigation |
| REST API Client | Backend communication |
| SharedPreferences | Local preferences and supported lightweight storage |

### Backend

| Technology | Purpose |
|---|---|
| Python | Backend programming language |
| FastAPI | API framework |
| Uvicorn | ASGI server |
| Pydantic | Data validation |
| bcrypt / Passlib | Password hashing integration |
| JWT | Authentication tokens |
| Google OAuth verification | Identity verification |

### Database and Infrastructure

| Technology | Purpose |
|---|---|
| PostgreSQL | Relational database |
| Docker | Containerization |
| Git | Version control |
| GitHub | Source code and collaboration |
| Vercel | Potential web frontend hosting |
| Cloud hosting | Backend deployment target |

---

## 📂 Project Structure

The following is a representative structure of the application.

```text
orgaflow_app/
│
├── android/
├── assets/
│   └── images/
│       └── orgaflow_logo.png
│
├── lib/
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
│   ├── requirements.txt
│   ├── Dockerfile
│   └── ...
│
├── pubspec.yaml
├── pubspec.lock
├── README.md
└── .gitignore
```

Your actual directory structure may contain additional modules, controllers, models, and pages.

---

## 🚀 Getting Started

Follow these steps to run the application locally.

### Prerequisites

Install the following tools:

- Flutter SDK.
- Dart SDK compatible with your Flutter installation.
- Android Studio and Android SDK.
- Python 3.
- PostgreSQL.
- Git.
- Docker, if running the backend in containers.

### 1. Clone the Repository

```bash
git clone https://github.com/Sumit-singh2398/orgaflow_app.git
cd orgaflow_app
```

### 2. Set Up the Flutter Application

```bash
flutter doctor
flutter pub get
```

Verify that your Flutter dependencies are installed correctly.

### 3. Configure the Backend

Open the backend directory:

```bash
cd orgaflow_backend
```

Create and activate a virtual environment on Windows:

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

Install dependencies:

```bash
pip install -r requirements.txt
```

### 4. Configure PostgreSQL

Create or configure the PostgreSQL database and user according to your local setup.

```sql
CREATE DATABASE orgaflow_db;
```

Configure the database connection using environment variables. Use the connection format expected by your backend.

### 5. Start FastAPI

```bash
uvicorn main:app --reload
```

The default local API address is:

```text
http://localhost:8000
```

Interactive API documentation:

```text
http://localhost:8000/docs
```

### 6. Run the Flutter Application

Open another terminal in the Flutter project root:

```bash
flutter devices
flutter run
```

For an Android APK build:

```bash
flutter build apk --release
```

The standard release APK output path is:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The APK build succeeds only if the required dependencies, Android configuration, signing configuration, and application code are valid.

---

## ⚙️ Environment Configuration

Keep local credentials in environment variables or an appropriately excluded local environment file.

Example configuration template:

```dotenv
DATABASE_URL=postgresql://USER:PASSWORD@HOST:5432/orgaflow_db
JWT_SECRET_KEY=replace_with_a_strong_random_secret
GOOGLE_CLIENT_ID=your_google_oauth_client_id
```

These are illustrative variable names. The actual backend must read the same names that you configure.

### Security Checklist

- Do not commit real database passwords.
- Do not commit production JWT signing secrets.
- Do not expose service account private keys.
- Keep production credentials outside the repository.
- Add appropriate local secret files to `.gitignore`.
- Restrict API keys where supported.
- Never use a secret value directly in the README.

---

## 📈 Development Status

Orgaflow is actively being developed. The following table separates established core functionality from work that remains planned or requires further verification.

| Feature | Status |
|---|---|
| Flutter application | Implemented |
| Employee portal UI | Implemented |
| Authentication UI | Implemented |
| Email/password signup and login | Implemented |
| Password hashing | Implemented |
| JWT authentication | Implemented |
| Google OAuth integration | Implemented |
| FastAPI backend | Implemented |
| PostgreSQL integration | Implemented |
| Employee asset requests | Implemented |
| Request persistence | Implemented |
| Employee request tracking | Implemented |
| Asset Manager request interface | Implemented |
| Request approval and rejection | Implemented |
| Rejection reason handling | Implemented |
| Backend role authorization | Implemented |
| Complete asset inventory CRUD | In progress |
| Asset assignment and return | Planned / verify implementation |
| Full maintenance workflow | In progress |
| Department analytics | Planned |
| Audit logging | Planned |
| Notification system | Planned |
| Production cloud deployment | In progress |

*Statuses describe the known development state and should be updated as individual features are completed and tested.*

---

## 🗺️ Roadmap

### Phase 1 — Core MVP

- [x] Authentication.
- [x] Employee portal.
- [x] Google OAuth integration.
- [x] JWT authentication.
- [x] PostgreSQL integration.
- [x] FastAPI backend.
- [x] Asset browsing interface.
- [x] Employee asset requests.
- [x] Request tracking.
- [x] Manager approval and rejection.
- [x] Rejection reason support.
- [x] Role-based authorization.

### Phase 2 — Asset Operations

- [ ] Complete asset inventory CRUD.
- [ ] Asset assignment.
- [ ] Asset return.
- [ ] Asset transfer.
- [ ] Asset replacement.
- [ ] Asset retirement.
- [ ] Serial number tracking.
- [ ] Warranty tracking.
- [ ] Location management.

### Phase 3 — Maintenance

- [ ] Maintenance tickets.
- [ ] Repair workflows.
- [ ] Maintenance scheduling.
- [ ] Service records.
- [ ] Maintenance cost tracking.
- [ ] Asset downtime tracking.
- [ ] Maintenance history.

### Phase 4 — Analytics and Reporting

- [ ] Executive dashboard.
- [ ] Asset utilization analytics.
- [ ] Department analytics.
- [ ] Request analytics.
- [ ] Maintenance analytics.
- [ ] Cost analytics.
- [ ] Advanced charts.
- [ ] Exportable reports.

### Phase 5 — Enterprise Capabilities

- [ ] Audit logging.
- [ ] Email notifications.
- [ ] Push notifications.
- [ ] Advanced permissions.
- [ ] Multi-organization support.
- [ ] Organization-level data isolation.
- [ ] Backup and recovery.
- [ ] Advanced security monitoring.

---

## 🔮 Future Enhancements

Potential extensions include:

- QR code-based asset identification.
- Barcode scanning.
- Automated warranty reminders.
- Maintenance notifications.
- Asset utilization reports.
- CSV and PDF report exports.
- Department-wise budget tracking.
- Multi-organization management.
- Audit trails for critical operations.
- Automated testing and CI/CD pipelines.

These are future possibilities, not claims of existing functionality.

---

## 🤝 Contributing

Orgaflow is currently under active development.

Suggestions, bug reports, documentation improvements, and feature ideas are welcome when the repository is open for contributions.

### Contribution Workflow

1. Fork the repository.
2. Create a feature branch.
3. Implement the change.
4. Run relevant tests.
5. Commit your changes.
6. Push the branch.
7. Open a pull request.

```bash
git checkout -b feature/your-feature
git add path/to/changed-file
git commit -m "Add: describe your change"
git push origin feature/your-feature
```

Please do not commit passwords, private keys, database credentials, or other secrets.

---

## 👨‍💻 Developer

<div align="center">

  <h3>Sumit Singh</h3>

  **BCA Student | Flutter Developer | Full-Stack Developer**

  Building practical applications with Flutter, Python, REST APIs, and relational databases.

  [![GitHub](https://img.shields.io/badge/GitHub-Sumit--singh2398-181717?logo=github)](https://github.com/Sumit-singh2398)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?logo=linkedin&logoColor=white)](https://linkedin.com/in/sumit-singh-975b7b412)

</div>

### Technologies Used

```text
Flutter • Dart • Python • FastAPI
PostgreSQL • REST APIs • JWT
Google OAuth • Docker • Git • GitHub
```

---

## 📌 Project Information

| Property | Details |
|---|---|
| Project Name | Orgaflow |
| Category | Enterprise Asset & Resource Management |
| Application | Full-stack application |
| Frontend | Flutter |
| Programming Language | Dart |
| Backend | FastAPI |
| Backend Language | Python |
| Database | PostgreSQL |
| Authentication | JWT + Google OAuth |
| Authorization | Role-Based Access Control |
| API Architecture | REST |
| Containerization | Docker |
| Version Control | Git and GitHub |
| Development Status | Active Development |

---

## 📄 License

Orgaflow is currently a student and portfolio project.

A formal license should be added before distributing the source code as an open-source project. Until a license is included, do not assume that others have permission to reuse, modify, or redistribute the code.

---

<div align="center">

  <h2>🚀 ORGAFLOW</h2>

  **Manage Assets. Automate Requests. Empower Organizations.**

  Built with Flutter, Dart, FastAPI, PostgreSQL, JWT, Google OAuth, and Docker.

  <sub>Designed and developed by Sumit Singh.</sub>

</div>
