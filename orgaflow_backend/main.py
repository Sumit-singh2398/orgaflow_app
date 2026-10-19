import os
import hmac
import hashlib
import secrets
import smtplib
from email.message import EmailMessage
from datetime import datetime, timedelta, timezone
from typing import Optional

import jwt
import psycopg2
import psycopg2.extras

from psycopg2.extras import RealDictCursor
from fastapi import FastAPI, Header, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, Field


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

APP_NAME = "Orgaflow API"

JWT_SECRET_KEY = os.getenv(
    "JWT_SECRET_KEY",
    "CHANGE_THIS_SECRET_BEFORE_DEPLOYMENT"
)

JWT_ALGORITHM = "HS256"

ACCESS_TOKEN_MINUTES = int(
    os.getenv("ACCESS_TOKEN_MINUTES", "1440")
)

DB_CONFIG = {
    "host": os.getenv("ORGAFLOW_DB_HOST", "localhost"),
    "port": int(os.getenv("ORGAFLOW_DB_PORT", "5432")),
    "dbname": os.getenv("ORGAFLOW_DB_NAME", "orgaflow_db"),
    "user": os.getenv("ORGAFLOW_DB_USER", "postgres"),
    "password": os.getenv("ORGAFLOW_DB_PASSWORD", "mehra"),
    "connect_timeout": 8,
}

app = FastAPI(
    title=APP_NAME,
    version="1.0.0",
    description="Orgaflow Asset Management API"
)

# Development configuration. Restrict origins in production.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Database connection
# ---------------------------------------------------------------------------

def get_connection():
    try:
        return psycopg2.connect(**DB_CONFIG)
    except psycopg2.Error as exc:
        print(
            f"[DATABASE CONNECTION ERROR] "
            f"{type(exc).__name__}: {exc}"
        )
        raise HTTPException(
            status_code=503,
            detail=(
                "Could not connect to PostgreSQL. "
                "Check database settings and server status."
            ),
        ) from exc


# ---------------------------------------------------------------------------
# Database initialization
# ---------------------------------------------------------------------------

def initialize_database():
    """
    Create required tables if they do not exist.
    Add a few demo assets when their codes are not already present.
    """
    conn = None

    try:
        conn = psycopg2.connect(**DB_CONFIG)

        with conn.cursor() as cur:

            cur.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id BIGSERIAL PRIMARY KEY,
                    full_name VARCHAR(150) NOT NULL,
                    email VARCHAR(320) UNIQUE NOT NULL,
                    password_hash TEXT NOT NULL,
                    role VARCHAR(40) NOT NULL DEFAULT 'EMPLOYEE',
                    department VARCHAR(120) NOT NULL DEFAULT '',
                    is_active BOOLEAN NOT NULL DEFAULT TRUE,
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
            """)

            cur.execute("""
                CREATE TABLE IF NOT EXISTS assets (
                    id BIGSERIAL PRIMARY KEY,
                    asset_code VARCHAR(80) UNIQUE NOT NULL,
                    asset_name VARCHAR(200) NOT NULL,
                    category VARCHAR(100) NOT NULL DEFAULT 'General',
                    department VARCHAR(120) NOT NULL DEFAULT '',
                    status VARCHAR(30) NOT NULL DEFAULT 'Available',
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
            """)

            cur.execute("""
                CREATE TABLE IF NOT EXISTS asset_assignments (
                    id BIGSERIAL PRIMARY KEY,
                    asset_code VARCHAR(80) NOT NULL,
                    asset_name VARCHAR(200) NOT NULL,
                    employee_name VARCHAR(150) NOT NULL,
                    employee_email VARCHAR(320) NOT NULL,
                    department VARCHAR(120) NOT NULL,
                    description TEXT NOT NULL DEFAULT '',
                    status VARCHAR(30) NOT NULL DEFAULT 'Assigned',
                    assigned_by BIGINT NULL
                        REFERENCES users(id) ON DELETE SET NULL,
                    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                    returned_at TIMESTAMPTZ NULL
                )
            """)

            cur.execute("""
                CREATE UNIQUE INDEX IF NOT EXISTS
                    uq_asset_assignments_active_asset
                ON asset_assignments (asset_code)
                WHERE status = 'Assigned'
            """)

            cur.execute("""
                CREATE TABLE IF NOT EXISTS audit_logs (
                    id BIGSERIAL PRIMARY KEY,
                    actor_user_id BIGINT NULL
                        REFERENCES users(id) ON DELETE SET NULL,
                    action VARCHAR(120) NOT NULL,
                    details JSONB NOT NULL DEFAULT '{}'::jsonb,
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
            """)

            demo_assets = [
                (
                    "AST-001",
                    "Dell Latitude Laptop",
                    "Laptop",
                    "IT",
                ),
                (
                    "AST-002",
                    "HP LaserJet Printer",
                    "Printer",
                    "Administration",
                ),
                (
                    "AST-003",
                    "Samsung Monitor",
                    "Monitor",
                    "IT",
                ),
                (
                    "AST-004",
                    "Logitech Keyboard",
                    "Accessory",
                    "IT",
                ),
                (
                    "AST-005",
                    "Office Projector",
                    "Projector",
                    "Conference",
                ),
            ]

            for code, name, category, department in demo_assets:
                cur.execute("""
                    INSERT INTO assets (
                        asset_code,
                        asset_name,
                        category,
                        department,
                        status
                    )
                    VALUES (%s, %s, %s, %s, 'Available')
                    ON CONFLICT (asset_code) DO NOTHING
                """, (code, name, category, department))

        conn.commit()
        print("[DATABASE] Tables initialized successfully.")

    except psycopg2.Error as exc:
        if conn:
            conn.rollback()

        print(
            f"[DATABASE INITIALIZATION ERROR] "
            f"{type(exc).__name__}: {exc}"
        )
        raise

    finally:
        if conn:
            conn.close()


@app.on_event("startup")
def startup_event():
    initialize_database()


# ---------------------------------------------------------------------------
# Request models
# ---------------------------------------------------------------------------

class RegisterIn(BaseModel):
    full_name: str = Field(min_length=2, max_length=150)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    department: str = Field(default="", max_length=120)


class LoginIn(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class AssetIn(BaseModel):
    asset_code: str = Field(min_length=1, max_length=80)
    asset_name: str = Field(min_length=1, max_length=200)
    category: str = Field(default="General", max_length=100)
    department: str = Field(default="", max_length=120)


class AssetAssignmentIn(BaseModel):
    asset_code: str = Field(min_length=1, max_length=80)
    asset_name: str = Field(min_length=1, max_length=200)
    employee_name: str = Field(min_length=2, max_length=150)
    employee_email: EmailStr
    department: str = Field(min_length=1, max_length=120)
    description: str = Field(default="", max_length=2000)


class AssignmentStatusIn(BaseModel):
    status: str = Field(min_length=1, max_length=30)


# ---------------------------------------------------------------------------
# Password hashing and verification
# ---------------------------------------------------------------------------

def hash_password(
    password: str,
    salt: Optional[bytes] = None
) -> str:
    salt = salt or secrets.token_bytes(16)

    digest = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt,
        310_000
    )

    return f"{salt.hex()}${digest.hex()}"


def verify_password(password: str, encoded: str) -> bool:
    try:
        salt_hex, digest_hex = encoded.split("$", 1)

        calculated = hashlib.pbkdf2_hmac(
            "sha256",
            password.encode("utf-8"),
            bytes.fromhex(salt_hex),
            310_000
        ).hex()

        return hmac.compare_digest(calculated, digest_hex)

    except (ValueError, TypeError):
        return False


# ---------------------------------------------------------------------------
# JWT authentication
# ---------------------------------------------------------------------------

def create_access_token(user: dict) -> str:
    now = datetime.now(timezone.utc)

    payload = {
        "sub": str(user["id"]),
        "email": user["email"],
        "role": user["role"],
        "iat": now,
        "exp": now + timedelta(
            minutes=ACCESS_TOKEN_MINUTES
        ),
    }

    return jwt.encode(
        payload,
        JWT_SECRET_KEY,
        algorithm=JWT_ALGORITHM
    )


def get_current_user(
    authorization: Optional[str] = Header(default=None)
) -> dict:

    if (
        not authorization
        or not authorization.lower().startswith("bearer ")
    ):
        raise HTTPException(
            status_code=401,
            detail="Bearer access token is required."
        )

    token = authorization.split(" ", 1)[1].strip()

    try:
        payload = jwt.decode(
            token,
            JWT_SECRET_KEY,
            algorithms=[JWT_ALGORITHM]
        )

        user_id = int(payload.get("sub", ""))

    except (jwt.PyJWTError, ValueError, TypeError):
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired access token."
        )

    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute("""
                SELECT
                    id,
                    full_name,
                    email,
                    role,
                    department,
                    is_active
                FROM users
                WHERE id = %s
            """, (user_id,))

            user = cur.fetchone()

        if not user or not user["is_active"]:
            raise HTTPException(
                status_code=401,
                detail="User does not exist or is inactive."
            )

        return dict(user)

    finally:
        conn.close()


def require_roles(*allowed_roles):
    def checker(
        user: dict = Depends(get_current_user)
    ):
        role = (
            str(user.get("role", ""))
            .upper()
            .replace(" ", "_")
        )

        if role not in allowed_roles:
            raise HTTPException(
                status_code=403,
                detail="You do not have permission for this action."
            )

        return user

    return checker


def normalize_role(role: str) -> str:
    role = role.strip().upper().replace(" ", "_")

    aliases = {
        "ASSETMANAGER": "ASSET_MANAGER",
        "DEPARTMENTHEAD": "DEPARTMENT_HEAD",
        "SUPERADMIN": "ADMIN",
    }

    return aliases.get(role, role)


# ---------------------------------------------------------------------------
# Email helper
# ---------------------------------------------------------------------------

def send_asset_assignment_email(
    recipient: str,
    employee_name: str,
    asset_code: str,
    asset_name: str,
    department: str,
    description: str,
    assignment_id: int,
    assigned_at: str,
):
    smtp_host = os.getenv("SMTP_HOST", "").strip()
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USER", "").strip()
    smtp_password = os.getenv("SMTP_PASSWORD", "")
    sender = os.getenv("SMTP_FROM", smtp_user).strip()

    use_ssl = (
        os.getenv("SMTP_USE_SSL", "false").lower()
        == "true"
    )

    if not all([
        smtp_host,
        smtp_user,
        smtp_password,
        sender
    ]):
        raise RuntimeError(
            "SMTP is not configured. Set SMTP_HOST, "
            "SMTP_USER, SMTP_PASSWORD and SMTP_FROM."
        )

    message = EmailMessage()
    message["Subject"] = (
        f"Orgaflow asset assigned: {asset_code}"
    )
    message["From"] = sender
    message["To"] = recipient

    message.set_content(f"""Hello {employee_name},

An asset has been assigned to you in Orgaflow.

Assignment ID: {assignment_id}
Asset: {asset_name}
Asset Code: {asset_code}
Department: {department}
Assignment Date (UTC): {assigned_at}

Purpose / Instructions:
{description or "No additional instructions were provided."}

If you believe this assignment is incorrect, contact your Asset Manager.

Regards,
Orgaflow Asset Management
""")

    if use_ssl:
        with smtplib.SMTP_SSL(
            smtp_host,
            smtp_port,
            timeout=20
        ) as server:
            server.login(smtp_user, smtp_password)
            server.send_message(message)

    else:
        with smtplib.SMTP(
            smtp_host,
            smtp_port,
            timeout=20
        ) as server:
            server.ehlo()
            server.starttls()
            server.ehlo()
            server.login(smtp_user, smtp_password)
            server.send_message(message)


# ---------------------------------------------------------------------------
# Basic and health endpoints
# ---------------------------------------------------------------------------

@app.get("/")
def root():
    return {
        "success": True,
        "app": APP_NAME,
        "docs": "/docs"
    }


@app.get("/health")
def health():
    conn = get_connection()

    try:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")

        return {
            "success": True,
            "database": "connected"
        }

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Authentication: register
# ---------------------------------------------------------------------------

@app.post("/api/auth/register", status_code=201)
@app.post("/register", status_code=201)
def register(payload: RegisterIn):

    email = str(payload.email).strip().lower()
    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute(
                "SELECT id FROM users WHERE email = %s",
                (email,)
            )

            if cur.fetchone():
                raise HTTPException(
                    status_code=409,
                    detail=(
                        "An account with this email "
                        "already exists."
                    )
                )

            cur.execute("""
                INSERT INTO users (
                    full_name,
                    email,
                    password_hash,
                    role,
                    department
                )
                VALUES (%s, %s, %s, 'EMPLOYEE', %s)
                RETURNING
                    id,
                    full_name,
                    email,
                    role,
                    department
            """, (
                payload.full_name.strip(),
                email,
                hash_password(payload.password),
                payload.department.strip()
            ))

            user = dict(cur.fetchone())

        conn.commit()

        token = create_access_token(user)

        return {
            "success": True,
            "access_token": token,
            "token": token,
            "token_type": "bearer",
            "user": user,
            **user,
        }

    except HTTPException:
        conn.rollback()
        raise

    except psycopg2.Error as exc:
        conn.rollback()

        print(
            f"[REGISTER DATABASE ERROR] "
            f"{type(exc).__name__}: {exc}"
        )

        raise HTTPException(
            status_code=500,
            detail="Could not create the account."
        ) from exc

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Authentication: login
# ---------------------------------------------------------------------------

@app.post("/api/auth/login")
@app.post("/login")
def login(payload: LoginIn):

    email = str(payload.email).strip().lower()
    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute("""
                SELECT
                    id,
                    full_name,
                    email,
                    password_hash,
                    role,
                    department,
                    is_active
                FROM users
                WHERE email = %s
            """, (email,))

            row = cur.fetchone()

        if (
            not row
            or not verify_password(
                payload.password,
                row["password_hash"]
            )
        ):
            raise HTTPException(
                status_code=401,
                detail="Incorrect email or password."
            )

        if not row["is_active"]:
            raise HTTPException(
                status_code=403,
                detail="This account is inactive."
            )

        user = {
            "id": row["id"],
            "full_name": row["full_name"],
            "email": row["email"],
            "role": row["role"],
            "department": row["department"],
        }

        token = create_access_token(user)

        return {
            "success": True,
            "access_token": token,
            "token": token,
            "token_type": "bearer",
            "user": user,
            **user,
        }

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Current logged-in user
# ---------------------------------------------------------------------------

@app.get("/api/auth/me")
@app.get("/me")
def me(
    user: dict = Depends(get_current_user)
):
    return {
        "success": True,
        "user": user,
        **user
    }


# ---------------------------------------------------------------------------
# List assets
# ---------------------------------------------------------------------------

@app.get("/api/assets")
def list_assets(
    user: dict = Depends(get_current_user)
):
    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute("""
                SELECT
                    id,
                    asset_code,
                    asset_name,
                    category,
                    department,
                    status,
                    created_at,
                    updated_at
                FROM assets
                ORDER BY id DESC
            """)

            rows = [
                dict(row)
                for row in cur.fetchall()
            ]

        return {
            "success": True,
            "assets": rows,
            "items": rows
        }

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Create asset
# ---------------------------------------------------------------------------

@app.post("/api/assets", status_code=201)
def create_asset(
    payload: AssetIn,
    user: dict = Depends(
        require_roles("ADMIN", "ASSET_MANAGER")
    ),
):
    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute("""
                INSERT INTO assets (
                    asset_code,
                    asset_name,
                    category,
                    department,
                    status
                )
                VALUES (%s, %s, %s, %s, 'Available')
                RETURNING
                    id,
                    asset_code,
                    asset_name,
                    category,
                    department,
                    status,
                    created_at
            """, (
                payload.asset_code.strip(),
                payload.asset_name.strip(),
                payload.category.strip(),
                payload.department.strip()
            ))

            row = dict(cur.fetchone())

            cur.execute("""
                INSERT INTO audit_logs (
                    actor_user_id,
                    action,
                    details
                )
                VALUES (%s, 'ASSET_CREATED', %s::jsonb)
            """, (
                user["id"],
                psycopg2.extras.Json({
                    "asset_code": payload.asset_code.strip()
                })
            ))

        conn.commit()

        return {
            "success": True,
            "asset": row,
            **row
        }

    except psycopg2.errors.UniqueViolation as exc:
        conn.rollback()

        raise HTTPException(
            status_code=409,
            detail="An asset with this code already exists."
        ) from exc

    except psycopg2.Error as exc:
        conn.rollback()

        print(
            f"[CREATE ASSET ERROR] "
            f"{type(exc).__name__}: {exc}"
        )

        raise HTTPException(
            status_code=500,
            detail="Could not create asset."
        ) from exc

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Assign asset to an employee and send email
# ---------------------------------------------------------------------------

@app.post("/api/assets/assign", status_code=201)
def assign_asset(
    payload: AssetAssignmentIn,
    user: dict = Depends(
        require_roles("ADMIN", "ASSET_MANAGER")
    ),
):
    asset_code = payload.asset_code.strip()
    asset_name = payload.asset_name.strip()
    employee_email = (
        str(payload.employee_email).strip().lower()
    )

    conn = get_connection()
    assignment = None

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            # Check whether the asset exists.
            cur.execute("""
                SELECT id, asset_name, status
                FROM assets
                WHERE asset_code = %s
                FOR UPDATE
            """, (asset_code,))

            asset = cur.fetchone()

            # If it does not exist, create it for local testing.
            if not asset:
                cur.execute("""
                    INSERT INTO assets (
                        asset_code,
                        asset_name,
                        status
                    )
                    VALUES (%s, %s, 'Available')
                    RETURNING id, asset_name, status
                """, (asset_code, asset_name))

                asset = cur.fetchone()

            # Do not assign the same asset twice.
            if asset["status"] == "Assigned":

                cur.execute("""
                    SELECT id
                    FROM asset_assignments
                    WHERE asset_code = %s
                      AND status = 'Assigned'
                    LIMIT 1
                """, (asset_code,))

                if cur.fetchone():
                    raise HTTPException(
                        status_code=409,
                        detail="This asset is already assigned."
                    )

            cur.execute("""
                INSERT INTO asset_assignments (
                    asset_code,
                    asset_name,
                    employee_name,
                    employee_email,
                    department,
                    description,
                    status,
                    assigned_by
                )
                VALUES (
                    %s, %s, %s, %s, %s, %s, 'Assigned', %s
                )
                RETURNING id, assigned_at
            """, (
                asset_code,
                asset_name,
                payload.employee_name.strip(),
                employee_email,
                payload.department.strip(),
                payload.description.strip(),
                user["id"]
            ))

            assignment = dict(cur.fetchone())

            # Update inventory status.
            cur.execute("""
                UPDATE assets
                SET status = 'Assigned',
                    updated_at = NOW()
                WHERE asset_code = %s
            """, (asset_code,))

            # Add audit log.
            cur.execute("""
                INSERT INTO audit_logs (
                    actor_user_id,
                    action,
                    details
                )
                VALUES (%s, 'ASSET_ASSIGNED', %s::jsonb)
            """, (
                user["id"],
                psycopg2.extras.Json({
                    "assignment_id": assignment["id"],
                    "asset_code": asset_code,
                    "employee_email": employee_email,
                })
            ))

        conn.commit()

    except HTTPException:
        conn.rollback()
        raise

    except psycopg2.errors.UniqueViolation as exc:
        conn.rollback()

        raise HTTPException(
            status_code=409,
            detail=(
                "This asset already has an active assignment."
            )
        ) from exc

    except psycopg2.Error as exc:
        conn.rollback()

        print(
            f"[ASSIGNMENT DATABASE ERROR] "
            f"{type(exc).__name__}: {exc}"
        )

        raise HTTPException(
            status_code=500,
            detail="Database error while saving the assignment."
        ) from exc

    finally:
        conn.close()

    assigned_at = (
        assignment["assigned_at"]
        .astimezone(timezone.utc)
        .isoformat()
    )

    # The assignment is saved even if email delivery fails.
    email_sent = False

    try:
        send_asset_assignment_email(
            recipient=employee_email,
            employee_name=payload.employee_name.strip(),
            asset_code=asset_code,
            asset_name=asset_name,
            department=payload.department.strip(),
            description=payload.description.strip(),
            assignment_id=int(assignment["id"]),
            assigned_at=assigned_at,
        )

        email_sent = True
        message = "Assignment saved and email sent."

    except Exception as exc:
        message = (
            "Assignment saved, but email delivery failed. "
            "Check SMTP settings."
        )

        print(
            f"[ASSET ASSIGNMENT EMAIL ERROR] "
            f"{type(exc).__name__}: {exc}"
        )

    return {
        "success": True,
        "assignment_id": int(assignment["id"]),
        "id": int(assignment["id"]),
        "asset_code": asset_code,
        "asset_name": asset_name,
        "employee_name": payload.employee_name.strip(),
        "employee_email": employee_email,
        "department": payload.department.strip(),
        "description": payload.description.strip(),
        "status": "Assigned",
        "assigned_at": assigned_at,
        "email_sent": email_sent,
        "message": message,
    }


# ---------------------------------------------------------------------------
# List all assignments
# ---------------------------------------------------------------------------

@app.get("/api/assets/assignments")
def list_assignments(
    user: dict = Depends(
        require_roles(
            "ADMIN",
            "ASSET_MANAGER",
            "DEPARTMENT_HEAD"
        )
    )
):
    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute("""
                SELECT
                    id,
                    asset_code,
                    asset_name,
                    employee_name,
                    employee_email,
                    department,
                    description,
                    status,
                    assigned_by,
                    assigned_at,
                    returned_at
                FROM asset_assignments
                ORDER BY assigned_at DESC
            """)

            rows = [
                dict(row)
                for row in cur.fetchall()
            ]

        return {
            "success": True,
            "assignments": rows,
            "items": rows
        }

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Update assignment status
# ---------------------------------------------------------------------------

@app.patch(
    "/api/assets/assignments/{assignment_id}/status"
)
def update_assignment_status(
    assignment_id: int,
    payload: AssignmentStatusIn,
    user: dict = Depends(
        require_roles("ADMIN", "ASSET_MANAGER")
    ),
):
    status = payload.status.strip().title()

    if status not in {
        "Assigned",
        "Returned",
        "Cancelled"
    }:
        raise HTTPException(
            status_code=422,
            detail=(
                "Status must be Assigned, Returned, or Cancelled."
            )
        )

    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute("""
                UPDATE asset_assignments
                SET
                    status = %s,
                    returned_at = CASE
                        WHEN %s IN ('Returned', 'Cancelled')
                        THEN NOW()
                        ELSE NULL
                    END
                WHERE id = %s
                RETURNING asset_code
            """, (
                status,
                status,
                assignment_id
            ))

            row = cur.fetchone()

            if not row:
                raise HTTPException(
                    status_code=404,
                    detail="Assignment not found."
                )

            new_asset_status = (
                "Assigned"
                if status == "Assigned"
                else "Available"
            )

            cur.execute("""
                UPDATE assets
                SET status = %s,
                    updated_at = NOW()
                WHERE asset_code = %s
            """, (
                new_asset_status,
                row["asset_code"]
            ))

        conn.commit()

        return {
            "success": True,
            "assignment_id": assignment_id,
            "status": status
        }

    except HTTPException:
        conn.rollback()
        raise

    except psycopg2.Error as exc:
        conn.rollback()

        print(
            f"[UPDATE ASSIGNMENT ERROR] "
            f"{type(exc).__name__}: {exc}"
        )

        raise HTTPException(
            status_code=500,
            detail="Could not update assignment status."
        ) from exc

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# List assets assigned to the logged-in employee
# ---------------------------------------------------------------------------

@app.get("/api/assets/my")
def my_assets(
    user: dict = Depends(get_current_user)
):
    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute("""
                SELECT
                    id,
                    asset_code,
                    asset_name,
                    department,
                    description,
                    status,
                    assigned_at
                FROM asset_assignments
                WHERE lower(employee_email) = lower(%s)
                  AND status = 'Assigned'
                ORDER BY assigned_at DESC
            """, (user["email"],))

            rows = [
                dict(row)
                for row in cur.fetchall()
            ]

        return {
            "success": True,
            "assets": rows,
            "items": rows
        }

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Audit logs
# ---------------------------------------------------------------------------

@app.get("/api/audit-logs")
def list_audit_logs(
    user: dict = Depends(
        require_roles("ADMIN", "ASSET_MANAGER")
    )
):
    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute("""
                SELECT
                    a.id,
                    a.action,
                    a.details,
                    a.created_at,
                    u.full_name AS actor_name,
                    u.email AS actor_email
                FROM audit_logs a
                LEFT JOIN users u
                    ON u.id = a.actor_user_id
                ORDER BY a.created_at DESC
                LIMIT 500
            """)

            rows = [
                dict(row)
                for row in cur.fetchall()
            ]

        return {
            "success": True,
            "logs": rows,
            "items": rows
        }

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Admin: list users
# ---------------------------------------------------------------------------

@app.get("/api/users")
def list_users(
    user: dict = Depends(require_roles("ADMIN"))
):
    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute("""
                SELECT
                    id,
                    full_name,
                    email,
                    role,
                    department,
                    is_active,
                    created_at
                FROM users
                ORDER BY id DESC
            """)

            rows = [
                dict(row)
                for row in cur.fetchall()
            ]

        return {
            "success": True,
            "users": rows,
            "items": rows
        }

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Admin: update a user's role
# ---------------------------------------------------------------------------

@app.patch("/api/users/{user_id}/role")
def update_user_role(
    user_id: int,
    role: str,
    user: dict = Depends(require_roles("ADMIN")),
):
    normalized = normalize_role(role)

    allowed = {
        "ADMIN",
        "ASSET_MANAGER",
        "DEPARTMENT_HEAD",
        "EMPLOYEE"
    }

    if normalized not in allowed:
        raise HTTPException(
            status_code=422,
            detail=(
                "Role must be one of: "
                + ", ".join(sorted(allowed))
            )
        )

    conn = get_connection()

    try:
        with conn.cursor(
            cursor_factory=RealDictCursor
        ) as cur:

            cur.execute("""
                UPDATE users
                SET role = %s
                WHERE id = %s
                RETURNING
                    id,
                    full_name,
                    email,
                    role,
                    department,
                    is_active
            """, (
                normalized,
                user_id
            ))

            row = cur.fetchone()

            if not row:
                raise HTTPException(
                    status_code=404,
                    detail="User not found."
                )

        conn.commit()

        return {
            "success": True,
            "user": dict(row)
        }

    except HTTPException:
        conn.rollback()
        raise

    except psycopg2.Error as exc:
        conn.rollback()

        raise HTTPException(
            status_code=500,
            detail="Could not update user role."
        ) from exc

    finally:
        conn.close()