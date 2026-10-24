
import os
from contextlib import asynccontextmanager
from datetime import datetime, timedelta, timezone

import psycopg2
from psycopg2.extras import RealDictCursor
from passlib.context import CryptContext
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from jose import jwt, JWTError
from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from dotenv import load_dotenv

load_dotenv()

# =========================================================
# CONFIGURATION
# =========================================================

DATABASE_URL = os.getenv("DATABASE_URL", "").strip()
GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID", "").strip()
JWT_SECRET = os.getenv("ORGAFLOW_JWT_SECRET", "").strip()
JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_MINUTES = 60 * 24 * 7

if not DATABASE_URL:
    print("WARNING: DATABASE_URL is not configured.")

if not JWT_SECRET or len(JWT_SECRET) < 32:
    print("WARNING: Set a strong ORGAFLOW_JWT_SECRET in Render.")

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Authoritative server-side account-role mapping.
ALLOWED_ACCOUNTS = {
    "singhsumit23578@gmail.com": "EMPLOYEE",
    "singhsumit98645@gmail.com": "ASSET_MANAGER",
    "mehra65749@gmail.com": "ADMIN",
    "singha96116@gmail.com": "DEPARTMENT_HEAD",
}


def get_connection():
    if not DATABASE_URL:
        raise RuntimeError("DATABASE_URL is not configured.")

    return psycopg2.connect(
        DATABASE_URL,
        connect_timeout=15,
        sslmode="require",
    )


def normalize_email(email):
    return (email or "").strip().lower()


def normalize_role(role):
    value = str(role or "").strip().upper()
    value = value.replace("-", "_").replace(" ", "_")

    aliases = {
        "ASSETMANAGER": "ASSET_MANAGER",
        "DEPARTMENTHEAD": "DEPARTMENT_HEAD",
    }
    return aliases.get(value.replace("_", ""), value)


def normalize_portal(portal):
    value = str(portal or "").strip().lower()
    if value == "employee":
        return "employee"
    if value in ("management", "manager", "admin"):
        return "management"
    return None


def role_for_email(email):
    return ALLOWED_ACCOUNTS.get(normalize_email(email))


def verify_email_role(email, selected_portal, selected_role=None):
    email = normalize_email(email)
    expected_role = role_for_email(email)

    if not expected_role:
        raise HTTPException(
            status_code=403,
            detail="This email is not authorized for Orgaflow.",
        )

    portal = normalize_portal(selected_portal)
    if not portal:
        raise HTTPException(status_code=400, detail="Invalid portal.")

    if portal == "employee":
        if expected_role != "EMPLOYEE":
            raise HTTPException(
                status_code=403,
                detail="This account cannot access the Employee portal.",
            )
        return expected_role

    if expected_role == "EMPLOYEE":
        raise HTTPException(
            status_code=403,
            detail="Employee accounts cannot access Management.",
        )

    if normalize_role(selected_role) != expected_role:
        raise HTTPException(
            status_code=403,
            detail="Selected management role does not match this account.",
        )

    return expected_role


# =========================================================
# DATABASE INITIALIZATION
# =========================================================

def initialize_database():
    """
    Creates the shared users table if it is missing and ensures
    the request, notification and Google OAuth tables exist.
    Does not drop or truncate existing data.
    """
    connection = get_connection()
    cursor = connection.cursor()

    try:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS public.users (
                id SERIAL PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                email VARCHAR(255) NOT NULL,
                password_hash TEXT NULL,
                role VARCHAR(50) NOT NULL DEFAULT 'EMPLOYEE',
                department_id INTEGER NULL,
                status VARCHAR(30) NOT NULL DEFAULT 'Active',
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
        """)

        cursor.execute("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_lower
            ON public.users (LOWER(email))
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS public.asset_requests (
                id SERIAL PRIMARY KEY,
                request_code VARCHAR(30) UNIQUE NOT NULL,
                user_id INTEGER NOT NULL,
                employee_name VARCHAR(150) NOT NULL,
                employee_email VARCHAR(255) NOT NULL,
                department VARCHAR(150),
                asset_id VARCHAR(100) NOT NULL,
                asset_name VARCHAR(255) NOT NULL,
                asset_category VARCHAR(150),
                asset_brand VARCHAR(150),
                asset_model VARCHAR(150),
                priority VARCHAR(30) NOT NULL DEFAULT 'Normal',
                description TEXT NOT NULL,
                status VARCHAR(30) NOT NULL DEFAULT 'Pending',
                rejection_reason TEXT,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                reviewed_at TIMESTAMP NULL,
                reviewed_by INTEGER NULL
            )
        """)

        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_asset_requests_user_id
            ON public.asset_requests(user_id)
        """)

        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_asset_requests_status
            ON public.asset_requests(status)
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS public.notifications (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL,
                title VARCHAR(200) NOT NULL,
                message TEXT NOT NULL,
                notification_type VARCHAR(50) NOT NULL DEFAULT 'general',
                request_id INTEGER NULL,
                is_read BOOLEAN NOT NULL DEFAULT FALSE,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
        """)

        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_notifications_user_id
            ON public.notifications(user_id)
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS public.oauth_users (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL,
                google_id VARCHAR(255) NOT NULL,
                email VARCHAR(255) NOT NULL,
                name VARCHAR(255),
                portal VARCHAR(30) NOT NULL DEFAULT 'employee',
                role VARCHAR(50),
                status VARCHAR(30) NOT NULL DEFAULT 'Active',
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
        """)

        cursor.execute("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_oauth_users_email_lower
            ON public.oauth_users (LOWER(email))
        """)

        connection.commit()
        print("ORGAFLOW DATABASE INITIALIZATION SUCCESSFUL")

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


@asynccontextmanager
async def lifespan(app):
    print("ORGAFLOW BACKEND STARTING")
    try:
        initialize_database()
    except Exception as exc:
        # Keep the service alive so health diagnostics can report failure.
        print("DATABASE INITIALIZATION FAILED:", str(exc))
    yield


app = FastAPI(
    title="Orgaflow Backend",
    version="1.3.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =========================================================
# JWT / AUTHENTICATION
# =========================================================

def create_access_token(user_id, email, role, portal):
    if not JWT_SECRET or len(JWT_SECRET) < 32:
        raise HTTPException(
            status_code=503,
            detail="Authentication is not configured on the server.",
        )

    expiry = datetime.now(timezone.utc) + timedelta(
        minutes=JWT_EXPIRATION_MINUTES
    )

    payload = {
        "user_id": user_id,
        "email": normalize_email(email),
        "role": role,
        "portal": portal,
        "exp": expiry,
    }

    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def get_current_user(authorization):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="A valid Bearer token is required.",
        )

    token = authorization[7:].strip()

    try:
        payload = jwt.decode(
            token,
            JWT_SECRET,
            algorithms=[JWT_ALGORITHM],
        )
    except JWTError:
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired token.",
        )

    user_id = payload.get("user_id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token.")

    return {
        "user_id": user_id,
        "email": payload.get("email"),
        "role": payload.get("role"),
        "portal": payload.get("portal"),
    }


def fetch_user_by_email(cursor, email):
    cursor.execute("""
        SELECT id, name, email, password_hash,
               role, department_id, status
        FROM public.users
        WHERE LOWER(email) = LOWER(%s)
        LIMIT 1
    """, (normalize_email(email),))
    return cursor.fetchone()


def fetch_user_by_id(user_id):
    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)
    try:
        cursor.execute("""
            SELECT id, name, email, role, department_id, status
            FROM public.users
            WHERE id = %s
        """, (user_id,))
        return cursor.fetchone()
    finally:
        cursor.close()
        connection.close()


def require_active_user(authorization):
    token_user = get_current_user(authorization)
    user = fetch_user_by_id(token_user["user_id"])

    if not user:
        raise HTTPException(status_code=401, detail="User not found.")

    if str(user["status"]).lower() != "active":
        raise HTTPException(status_code=403, detail="Account is inactive.")

    return {
        "token": token_user,
        "user": user,
        "role": normalize_role(user["role"]),
    }


def require_request_manager(authorization):
    current = require_active_user(authorization)
    if current["role"] not in {"ADMIN", "ASSET_MANAGER"}:
        raise HTTPException(
            status_code=403,
            detail="Only Admin or Asset Manager can manage requests.",
        )
    return current


# =========================================================
# RESPONSE HELPERS
# =========================================================

def user_response(user):
    return {
        "id": user["id"],
        "name": user["name"],
        "email": normalize_email(user["email"]),
        "role": normalize_role(user["role"]),
        "department_id": user.get("department_id"),
        "status": user["status"],
    }


def successful_login(user, portal):
    role = normalize_role(user["role"])
    token = create_access_token(
        user["id"],
        user["email"],
        role,
        portal,
    )
    return {
        "success": True,
        "message": "Login successful.",
        "access_token": token,
        "token_type": "bearer",
        "user": user_response(user),
    }


# =========================================================
# ROOT / HEALTH
# =========================================================

@app.get("/")
def root():
    return {
        "success": True,
        "message": "Orgaflow Backend is running",
        "version": "1.3.0",
    }


@app.get("/api/health")
def health_check():
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(cursor_factory=RealDictCursor)
        cursor.execute("""
            SELECT current_database() AS database_name,
                   current_user AS database_user,
                   to_regclass('public.users') AS users_table,
                   to_regclass('public.oauth_users') AS oauth_users_table
        """)
        info = cursor.fetchone()

        if not info["users_table"]:
            raise RuntimeError("public.users table is missing.")

        return {
            "success": True,
            "message": "Backend and database are connected.",
            "database": info["database_name"],
            "users_table_ready": True,
            "oauth_users_table_ready": bool(info["oauth_users_table"]),
        }

    except Exception as exc:
        print("HEALTH CHECK ERROR:", str(exc))
        raise HTTPException(
            status_code=503,
            detail="Database connection or schema check failed.",
        )
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


# =========================================================
# SIGNUP
# =========================================================

class SignupRequest(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    email: str
    password: str = Field(min_length=8, max_length=128)
    department_id: int | None = None


@app.post("/api/auth/signup")
def signup(data: SignupRequest):
    email = normalize_email(data.email)
    expected_role = role_for_email(email)

    # Public signup can create only the designated employee account.
    # Management roles cannot be assigned by public signup.
    if expected_role != "EMPLOYEE":
        raise HTTPException(
            status_code=403,
            detail="Public signup is only available for the authorized employee account.",
        )

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        existing = fetch_user_by_email(cursor, email)
        if existing:
            raise HTTPException(
                status_code=409,
                detail="This account already exists.",
            )

        password_hash = pwd_context.hash(data.password)

        cursor.execute("""
            INSERT INTO public.users
                (name, email, password_hash, role, department_id, status)
            VALUES (%s, %s, %s, 'EMPLOYEE', %s, 'Active')
            RETURNING id, name, email, role, department_id, status
        """, (
            data.name.strip(),
            email,
            password_hash,
            data.department_id,
        ))

        user = cursor.fetchone()
        connection.commit()

        return {
            "success": True,
            "message": "Signup successful.",
            "user": user_response(user),
        }

    except HTTPException:
        connection.rollback()
        raise
    except Exception as exc:
        connection.rollback()
        print("SIGNUP ERROR:", str(exc))
        raise HTTPException(status_code=500, detail="Signup failed.")
    finally:
        cursor.close()
        connection.close()


# =========================================================
# EMAIL / PASSWORD LOGIN
# =========================================================

class LoginRequest(BaseModel):
    email: str
    password: str
    portal: str = "employee"
    role: str | None = None


@app.post("/api/auth/login")
def login(data: LoginRequest):
    email = normalize_email(data.email)

    expected_role = verify_email_role(
        email,
        data.portal,
        data.role,
    )

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        user = fetch_user_by_email(cursor, email)

        if not user:
            raise HTTPException(
                status_code=401,
                detail=(
                    "Account not found. Create the employee account "
                    "or sign in with the authorized Google account."
                ),
            )

        if str(user["status"]).lower() != "active":
            raise HTTPException(status_code=403, detail="Account is inactive.")

        # Never trust the role stored in a client request.
        # The configured email-role mapping is authoritative.
        database_role = normalize_role(user["role"])
        if database_role != expected_role:
            raise HTTPException(
                status_code=403,
                detail="Database role does not match the authorized account mapping.",
            )

        password_hash = user.get("password_hash")
        if not password_hash:
            raise HTTPException(
                status_code=401,
                detail="This account has no password. Use Google login.",
            )

        if not pwd_context.verify(data.password, password_hash):
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password.",
            )

        return successful_login(user, normalize_portal(data.portal))

    except HTTPException:
        raise
    except Exception as exc:
        print("LOGIN ERROR:", str(exc))
        raise HTTPException(status_code=500, detail="Login failed.")
    finally:
        cursor.close()
        connection.close()


# =========================================================
# GOOGLE LOGIN
# =========================================================

@app.post("/api/auth/google-login")
def google_login(data: dict):
    credential = data.get("id_token") or data.get("credential")
    portal = normalize_portal(data.get("portal"))
    selected_role = data.get("role")

    if not credential:
        raise HTTPException(status_code=400, detail="Google ID token is required.")

    if not portal:
        raise HTTPException(status_code=400, detail="Invalid portal.")

    if not GOOGLE_CLIENT_ID:
        raise HTTPException(
            status_code=503,
            detail="Google Sign-In is not configured on the server.",
        )

    try:
        google_user = id_token.verify_oauth2_token(
            credential,
            google_requests.Request(),
            GOOGLE_CLIENT_ID,
        )
    except Exception as exc:
        print("GOOGLE TOKEN VERIFICATION ERROR:", str(exc))
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired Google ID token.",
        )

    email = normalize_email(google_user.get("email"))
    google_id = google_user.get("sub")
    name = google_user.get("name") or email.split("@")[0]

    if not email or not google_id:
        raise HTTPException(
            status_code=401,
            detail="Google account information is incomplete.",
        )

    # Verify the email-role mapping before creating or modifying records.
    expected_role = verify_email_role(email, portal, selected_role)

    # Require Google to confirm the email address.
    if google_user.get("email_verified") is not True:
        raise HTTPException(
            status_code=403,
            detail="Google email must be verified.",
        )

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        user = fetch_user_by_email(cursor, email)

        if user:
            # Do not silently promote an existing account.
            if normalize_role(user["role"]) != expected_role:
                raise HTTPException(
                    status_code=403,
                    detail="Database role does not match the configured account role.",
                )

            if str(user["status"]).lower() != "active":
                raise HTTPException(
                    status_code=403,
                    detail="Account is inactive.",
                )

        else:
            # Only the exact four configured Google accounts can be
            # created here, and their roles come from server config.
            cursor.execute("""
                INSERT INTO public.users
                    (name, email, password_hash, role, status)
                VALUES (%s, %s, NULL, %s, 'Active')
                RETURNING id, name, email, password_hash,
                          role, department_id, status
            """, (name, email, expected_role))
            user = cursor.fetchone()

        cursor.execute("""
            INSERT INTO public.oauth_users
                (user_id, google_id, email, name, portal, role, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (LOWER(email))
            DO UPDATE SET
                user_id = EXCLUDED.user_id,
                google_id = EXCLUDED.google_id,
                name = EXCLUDED.name,
                portal = EXCLUDED.portal,
                role = EXCLUDED.role,
                status = EXCLUDED.status,
                updated_at = CURRENT_TIMESTAMP
        """, (
            user["id"],
            google_id,
            email,
            name,
            portal,
            expected_role,
            user["status"],
        ))

        connection.commit()
        return successful_login(user, portal)

    except HTTPException:
        connection.rollback()
        raise
    except Exception as exc:
        connection.rollback()
        print("GOOGLE LOGIN DATABASE ERROR:", str(exc))
        raise HTTPException(status_code=500, detail="Google login failed.")
    finally:
        cursor.close()
        connection.close()


# =========================================================
# REQUEST MODELS
# =========================================================

class AssetRequestCreate(BaseModel):
    asset_id: str
    asset_name: str
    asset_category: str = ""
    asset_brand: str = ""
    asset_model: str = ""
    department: str = ""
    priority: str = "Normal"
    description: str


class RequestStatusUpdate(BaseModel):
    status: str
    rejection_reason: str | None = None


# =========================================================
# ASSET REQUEST APIs
# =========================================================

@app.post("/api/requests")
def create_asset_request(
    data: AssetRequestCreate,
    authorization: str | None = Header(default=None),
):
    current = require_active_user(authorization)
    user = current["user"]

    if current["role"] != "EMPLOYEE":
        raise HTTPException(
            status_code=403,
            detail="Only Employee accounts can create asset requests.",
        )

    if not data.asset_id.strip() or not data.asset_name.strip() or not data.description.strip():
        raise HTTPException(
            status_code=400,
            detail="Asset ID, asset name and description are required.",
        )

    allowed_priorities = {"Normal", "Urgent", "Low", "Medium", "High"}
    priority = data.priority.strip().title()
    if priority not in allowed_priorities:
        raise HTTPException(status_code=400, detail="Invalid priority.")

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            INSERT INTO public.asset_requests (
                request_code, user_id, employee_name, employee_email,
                department, asset_id, asset_name, asset_category,
                asset_brand, asset_model, priority, description, status
            )
            VALUES (
                'TEMP', %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, 'Pending'
            )
            RETURNING id
        """, (
            user["id"], user["name"], user["email"],
            data.department.strip() or None,
            data.asset_id.strip(), data.asset_name.strip(),
            data.asset_category.strip() or None,
            data.asset_brand.strip() or None,
            data.asset_model.strip() or None,
            priority, data.description.strip(),
        ))

        request_id = cursor.fetchone()["id"]
        request_code = f"REQ-{1000 + request_id}"

        cursor.execute("""
            UPDATE public.asset_requests
            SET request_code = %s
            WHERE id = %s
            RETURNING *
        """, (request_code, request_id))

        request = cursor.fetchone()
        connection.commit()
        return {"success": True, "request": request}

    except Exception as exc:
        connection.rollback()
        print("CREATE REQUEST ERROR:", str(exc))
        raise HTTPException(status_code=500, detail="Unable to create asset request.")
    finally:
        cursor.close()
        connection.close()


@app.get("/api/requests")
def get_all_requests(authorization: str | None = Header(default=None)):
    require_request_manager(authorization)
    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)
    try:
        cursor.execute("SELECT * FROM public.asset_requests ORDER BY created_at DESC")
        rows = cursor.fetchall()
        return {"success": True, "count": len(rows), "requests": rows}
    finally:
        cursor.close()
        connection.close()


@app.get("/api/requests/my")
def get_my_requests(authorization: str | None = Header(default=None)):
    current = require_active_user(authorization)
    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)
    try:
        cursor.execute("""
            SELECT * FROM public.asset_requests
            WHERE user_id = %s
            ORDER BY created_at DESC
        """, (current["user"]["id"],))
        rows = cursor.fetchall()
        return {"success": True, "count": len(rows), "requests": rows}
    finally:
        cursor.close()
        connection.close()


@app.get("/api/requests/{request_id}")
def get_single_request(
    request_id: int,
    authorization: str | None = Header(default=None),
):
    current = require_active_user(authorization)
    user = current["user"]
    role = current["role"]

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)
    try:
        cursor.execute(
            "SELECT * FROM public.asset_requests WHERE id = %s",
            (request_id,),
        )
        row = cursor.fetchone()

        if not row:
            raise HTTPException(status_code=404, detail="Request not found.")

        if role == "EMPLOYEE" and row["user_id"] != user["id"]:
            raise HTTPException(status_code=403, detail="Access denied.")

        if role not in {"EMPLOYEE", "ADMIN", "ASSET_MANAGER"}:
            raise HTTPException(status_code=403, detail="Access denied.")

        return {"success": True, "request": row}
    finally:
        cursor.close()
        connection.close()


@app.patch("/api/requests/{request_id}/status")
def update_request_status(
    request_id: int,
    data: RequestStatusUpdate,
    authorization: str | None = Header(default=None),
):
    current = require_request_manager(authorization)
    manager = current["user"]

    requested = data.status.strip().lower()
    if requested in {"approve", "approved"}:
        new_status = "Approved"
    elif requested in {"reject", "rejected", "not approved", "not_approved"}:
        new_status = "Rejected"
    else:
        raise HTTPException(
            status_code=400,
            detail="Status must be Approved or Rejected.",
        )

    reason = (data.rejection_reason or "").strip()
    if new_status == "Rejected" and not reason:
        raise HTTPException(
            status_code=400,
            detail="Rejection reason is required.",
        )

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            SELECT * FROM public.asset_requests
            WHERE id = %s
            FOR UPDATE
        """, (request_id,))
        request = cursor.fetchone()

        if not request:
            raise HTTPException(status_code=404, detail="Request not found.")

        if request["status"].lower() != "pending":
            raise HTTPException(status_code=409, detail="Request already reviewed.")

        cursor.execute("""
            UPDATE public.asset_requests
            SET status = %s, rejection_reason = %s,
                reviewed_at = CURRENT_TIMESTAMP,
                reviewed_by = %s,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = %s
            RETURNING *
        """, (
            new_status,
            reason if new_status == "Rejected" else None,
            manager["id"],
            request_id,
        ))
        updated = cursor.fetchone()

        if new_status == "Approved":
            title = "Asset Request Approved"
            message = f"Your request {request['request_code']} for {request['asset_name']} has been approved."
            notification_type = "request_approved"
        else:
            title = "Asset Request Rejected"
            message = f"Your request {request['request_code']} for {request['asset_name']} was rejected. Reason: {reason}"
            notification_type = "request_rejected"

        cursor.execute("""
            INSERT INTO public.notifications
                (user_id, title, message, notification_type, request_id)
            VALUES (%s, %s, %s, %s, %s)
        """, (
            request["user_id"], title, message,
            notification_type, request_id,
        ))

        connection.commit()
        return {
            "success": True,
            "message": "Request updated and notification created.",
            "request": updated,
        }

    except HTTPException:
        connection.rollback()
        raise
    except Exception as exc:
        connection.rollback()
        print("UPDATE REQUEST ERROR:", str(exc))
        raise HTTPException(status_code=500, detail="Unable to update request.")
    finally:
        cursor.close()
        connection.close()


@app.get("/api/requests/stats")
def get_request_stats(authorization: str | None = Header(default=None)):
    require_request_manager(authorization)
    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)
    try:
        cursor.execute("""
            SELECT COUNT(*) AS total,
                   COUNT(*) FILTER (WHERE status = 'Pending') AS pending,
                   COUNT(*) FILTER (WHERE status = 'Approved') AS approved,
                   COUNT(*) FILTER (WHERE status = 'Rejected') AS rejected
            FROM public.asset_requests
        """)
        stats = cursor.fetchone()
        return {"success": True, "stats": stats}
    finally:
        cursor.close()
        connection.close()


# =========================================================
# NOTIFICATION APIs
# =========================================================

@app.get("/api/notifications/me")
def get_my_notifications(authorization: str | None = Header(default=None)):
    current = require_active_user(authorization)
    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)
    try:
        cursor.execute("""
            SELECT id, title, message, notification_type,
                   request_id, is_read, created_at
            FROM public.notifications
            WHERE user_id = %s
            ORDER BY created_at DESC
            LIMIT 100
        """, (current["user"]["id"],))
        rows = cursor.fetchall()
        return {"success": True, "count": len(rows), "notifications": rows}
    finally:
        cursor.close()
        connection.close()


@app.get("/api/notifications/unread-count")
def get_unread_notification_count(
    authorization: str | None = Header(default=None),
):
    current = require_active_user(authorization)
    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)
    try:
        cursor.execute("""
            SELECT COUNT(*) AS unread_count
            FROM public.notifications
            WHERE user_id = %s AND is_read = FALSE
        """, (current["user"]["id"],))
        return {"success": True, **cursor.fetchone()}
    finally:
        cursor.close()
        connection.close()


@app.patch("/api/notifications/{notification_id}/read")
def mark_notification_as_read(
    notification_id: int,
    authorization: str | None = Header(default=None),
):
    current = require_active_user(authorization)
    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)
    try:
        cursor.execute("""
            UPDATE public.notifications
            SET is_read = TRUE
            WHERE id = %s AND user_id = %s
            RETURNING id, is_read
        """, (notification_id, current["user"]["id"]))

        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Notification not found.")

        connection.commit()
        return {"success": True, "notification": row}
    except HTTPException:
        connection.rollback()
        raise
    except Exception as exc:
        connection.rollback()
        print("MARK NOTIFICATION ERROR:", str(exc))
        raise HTTPException(status_code=500, detail="Unable to update notification.")
    finally:
        cursor.close()
        connection.close()


@app.patch("/api/notifications/read-all")
def mark_all_notifications_as_read(
    authorization: str | None = Header(default=None),
):
    current = require_active_user(authorization)
    connection = get_connection()
    cursor = connection.cursor()
    try:
        cursor.execute("""
            UPDATE public.notifications
            SET is_read = TRUE
            WHERE user_id = %s AND is_read = FALSE
        """, (current["user"]["id"],))
        count = cursor.rowcount
        connection.commit()
        return {"success": True, "updated_count": count}
    except Exception as exc:
        connection.rollback()
        print("MARK ALL NOTIFICATIONS ERROR:", str(exc))
        raise HTTPException(status_code=500, detail="Unable to update notifications.")
    finally:
        cursor.close()
        connection.close()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", "8000")),
        log_level="info",
    )
