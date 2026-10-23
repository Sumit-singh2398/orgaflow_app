from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
import psycopg2
from psycopg2.extras import RealDictCursor
from passlib.context import CryptContext
from google.oauth2 import id_token
from google.auth.transport import requests
from jose import jwt, JWTError
from pydantic import BaseModel
from datetime import datetime, timedelta, timezone
from contextlib import asynccontextmanager
import os
from dotenv import load_dotenv

ENV_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
load_dotenv(ENV_PATH)

# =========================================================
# STARTUP / LIFESPAN
# =========================================================
@asynccontextmanager
async def lifespan(app):
    print("ORGAFLOW BACKEND STARTING")

    try:
        create_request_table()
        create_notification_table()
        create_oauth_users_table()
        print("DATABASE INITIALIZATION SUCCESSFUL")

    except Exception as e:
        print("DATABASE INITIALIZATION FAILED:", e)
        print("Check PostgreSQL and required Orgaflow tables.")

    yield


# =========================================================
# APP CONFIG
# =========================================================
app = FastAPI(
    title="Orgaflow Backend",
    version="1.2.0",
    lifespan=lifespan
)

# =========================================================
# CORS
# =========================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================================================
# DATABASE CONFIG (NEON - console.neon.tech)
# =========================================================
# Neon Postgres ka connection string .env file mein hai.
#
# .env example:
#   DATABASE_URL=postgresql://USER:PASSWORD@ep-xxxx-xxxx.region.aws.neon.tech/neondb?sslmode=require
#
# Neon console se connection string copy karo:
#   console.neon.tech -> Project -> Dashboard -> "Connect" / "Connection string"
DATABASE_URL = os.getenv("DATABASE_URL", "").strip()

if not DATABASE_URL:
    raise RuntimeError(
        "DATABASE_URL is not set.\n\n"
        "Local run: create orgaflow_backend/.env with:\n"
        "  DATABASE_URL=postgresql://user:password@host/dbname?sslmode=require\n\n"
        "Render deploy: go to your service -> Environment tab ->\n"
        "  add 'DATABASE_URL' with your Neon pooled connection string,\n"
        "  then Save & Deploy.\n\n"
        "Neon console: https://console.neon.tech"
    )

# =========================================================
# GOOGLE CONFIG
# =========================================================
GOOGLE_CLIENT_ID = os.getenv(
    "GOOGLE_CLIENT_ID",
    "449981088129-fptar4p18jkmsgk6avhigqintmv0qha3.apps.googleusercontent.com"
)

# =========================================================
# JWT CONFIG
# =========================================================
JWT_SECRET = os.getenv(
    "ORGAFLOW_JWT_SECRET",
    "orgaflow_super_secret_key_change_later"
)
JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_MINUTES = 120 * 24 * 7

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)

# =========================================================
# DATABASE CONNECTION (NEON)
# =========================================================
def get_connection():
    # Neon hamesha SSL mande karta hai; agar DSN mein
    # sslmode missing ho to require inject karo.
    dsn = DATABASE_URL

    # Neon PgBouncer pooler does not support SCRAM channel_binding
    if "channel_binding=" in dsn:
        import re
        dsn = re.sub(r'([?&])channel_binding=[^&]*(&|$)', r'\1', dsn).rstrip('&?')

    if "sslmode=" not in dsn:
        dsn = dsn + ("&" if "?" in dsn else "?") + "sslmode=require"

    return psycopg2.connect(
        dsn,
        connect_timeout=15
    )


# =========================================================
# CREATE REQUEST TABLE
# =========================================================
def create_request_table():
    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

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
            CREATE INDEX IF NOT EXISTS idx_asset_requests_created_at
            ON public.asset_requests(created_at DESC)
        """)

        connection.commit()
        print("ASSET REQUEST TABLE READY")

    except Exception as e:
        if connection:
            connection.rollback()
        print("REQUEST TABLE ERROR:", e)
        raise

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


# =========================================================
# CREATE NOTIFICATIONS TABLE
# =========================================================
def create_notification_table():
    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

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
            CREATE INDEX IF NOT EXISTS idx_notifications_unread
            ON public.notifications(user_id, is_read)
        """)

        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_notifications_created_at
            ON public.notifications(created_at DESC)
        """)

        connection.commit()
        print("NOTIFICATIONS TABLE READY")

    except Exception as e:
        if connection:
            connection.rollback()
        print("NOTIFICATION TABLE ERROR:", e)
        raise

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


# =========================================================
# CREATE GOOGLE OAUTH LINK TABLE
# =========================================================
def create_oauth_users_table():
    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

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

        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_oauth_users_user_id
            ON public.oauth_users (user_id)
        """)

        connection.commit()
        print("OAUTH USERS TABLE READY")

    except Exception as e:
        if connection:
            connection.rollback()
        print("OAUTH USERS TABLE ERROR:", e)
        raise

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


# =========================================================
# STARTUP
# =========================================================
# =========================================================
# NORMALIZE PORTAL AND ROLES
# =========================================================
def normalize_portal(portal):
    if portal is None:
        return None

    value = str(portal).strip().lower()

    if value == "employee":
        return "employee"

    if value in ["management", "manager", "admin"]:
        return "management"

    return None


def normalize_role(role):
    if role is None:
        return None

    compact = (
        str(role).strip().replace(" ", "").replace("_", "").lower()
    )

    roles = {
        "admin": "ADMIN",
        "assetmanager": "ASSET_MANAGER",
        "departmenthead": "DEPARTMENT_HEAD",
        "employee": "EMPLOYEE"
    }

    return roles.get(compact, str(role).strip().upper())


def normalize_database_role(role):
    return normalize_role(role)


# =========================================================
# JWT TOKEN GENERATION
# =========================================================
def create_access_token(user_id, email, role, portal):
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=JWT_EXPIRATION_MINUTES
    )

    payload = {
        "user_id": user_id,
        "email": email,
        "role": role,
        "portal": portal,
        "exp": expire
    }

    return jwt.encode(
        payload,
        JWT_SECRET,
        algorithm=JWT_ALGORITHM
    )


# =========================================================
# GET CURRENT USER FROM JWT
# =========================================================
def get_current_user(authorization: str | None):
    if not authorization:
        raise HTTPException(
            status_code=401,
            detail="Authorization token is required."
        )

    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="Invalid authorization header."
        )

    token = authorization[len("Bearer "):].strip()

    if not token:
        raise HTTPException(
            status_code=401,
            detail="Authorization token is missing."
        )

    try:
        payload = jwt.decode(
            token,
            JWT_SECRET,
            algorithms=[JWT_ALGORITHM]
        )

        user_id = payload.get("user_id")

        if not user_id:
            raise HTTPException(
                status_code=401,
                detail="Invalid token."
            )

        return {
            "user_id": user_id,
            "email": payload.get("email"),
            "role": payload.get("role"),
            "portal": payload.get("portal")
        }

    except JWTError:
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired token."
        )


# =========================================================
# DATABASE USER / ACTIVE USER CHECK
# =========================================================
def get_database_user(user_id):
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


def require_active_user(authorization: str | None):
    token_user = get_current_user(authorization)
    user = get_database_user(token_user["user_id"])

    if not user:
        raise HTTPException(
            status_code=401,
            detail="User account not found."
        )

    if str(user["status"]).strip().lower() != "active":
        raise HTTPException(
            status_code=403,
            detail="User account is inactive."
        )

    return {
        "token": token_user,
        "user": user,
        "role": normalize_database_role(user["role"])
    }


def require_request_manager(authorization: str | None):
    current = require_active_user(authorization)

    if current["role"] not in {"ADMIN", "ASSET_MANAGER"}:
        raise HTTPException(
            status_code=403,
            detail="Only Admin or Asset Manager can manage requests."
        )

    return current


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
# ROOT
# =========================================================
@app.get("/")
def root():
    return {
        "success": True,
        "message": "Orgaflow Backend is running",
        "version": "1.2.0"
    }


# =========================================================
# HEALTH CHECK
# =========================================================
@app.get("/api/health")
def health_check():
    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()

        return {
            "success": True,
            "message": "Backend and database are connected."
        }

    except Exception as e:
        print("HEALTH CHECK ERROR:", e)

        raise HTTPException(
            status_code=503,
            detail="Backend is running but database connection failed."
        )

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


# =========================================================
# SIGNUP
# =========================================================
@app.post("/api/auth/signup")
def signup(data: dict):
    name = data.get("name")
    email = data.get("email")
    password = data.get("password")
    department_id = data.get("department_id")

    if not name or not email or not password:
        raise HTTPException(
            status_code=400,
            detail="Name, email and password are required."
        )

    email = email.strip().lower()
    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            SELECT id
            FROM public.users
            WHERE LOWER(email) = LOWER(%s)
        """, (email,))

        if cursor.fetchone():
            raise HTTPException(
                status_code=400,
                detail="User already exists."
            )

        password_hash = pwd_context.hash(password)

        cursor.execute("""
            INSERT INTO public.users (
                name, email, password_hash, role, department_id, status
            )
            VALUES (%s, %s, %s, 'Employee', %s, 'Active')
            RETURNING id, name, email, role, department_id, status
        """, (
            name.strip(),
            email,
            password_hash,
            department_id
        ))

        user = cursor.fetchone()
        connection.commit()

        return {
            "success": True,
            "message": "Signup successful.",
            "user": user
        }

    except HTTPException:
        connection.rollback()
        raise

    except Exception as e:
        connection.rollback()
        print("SIGNUP ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Signup failed."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# EMAIL / PASSWORD LOGIN
# =========================================================
@app.post("/api/auth/login")
def login(data: dict):
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        raise HTTPException(
            status_code=400,
            detail="Email and password are required."
        )

    email = email.strip().lower()
    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            SELECT id, name, email, password_hash,
                   role, department_id, status
            FROM public.users
            WHERE LOWER(email) = LOWER(%s)
        """, (email,))

        user = cursor.fetchone()

        if not user:
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password."
            )

        password_hash = user.get("password_hash")

        if not password_hash:
            raise HTTPException(
                status_code=401,
                detail="This account uses Google login."
            )

        if not pwd_context.verify(password, password_hash):
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password."
            )

        if str(user["status"]).strip().lower() != "active":
            raise HTTPException(
                status_code=403,
                detail="User account is inactive."
            )

        database_role = normalize_database_role(user["role"])

        token = create_access_token(
            user["id"],
            user["email"],
            database_role,
            "employee"
        )

        return {
            "success": True,
            "message": "Login successful.",
            "access_token": token,
            "token_type": "bearer",
            "user": {
                "id": user["id"],
                "name": user["name"],
                "email": user["email"],
                "role": database_role,
                "department_id": user["department_id"],
                "status": user["status"]
            }
        }

    except HTTPException:
        raise

    except Exception as e:
        print("LOGIN ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Login failed."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# VERIFY PORTAL AND ROLE
# =========================================================
def verify_portal_and_role(portal, selected_role, database_role):
    portal = normalize_portal(portal)
    selected_role = normalize_role(selected_role)
    database_role = normalize_database_role(database_role)

    if not portal:
        raise HTTPException(
            status_code=400,
            detail="Invalid portal."
        )

    if portal == "employee":
        if database_role not in {"EMPLOYEE", "ADMIN"}:
            raise HTTPException(
                status_code=403,
                detail=(
                    "This account is not allowed to access "
                    "Employee portal."
                )
            )
        return

    if portal == "management":
        allowed_roles = {
            "ADMIN",
            "ASSET_MANAGER",
            "DEPARTMENT_HEAD"
        }

        if not selected_role:
            raise HTTPException(
                status_code=400,
                detail="Management role is required."
            )

        if selected_role not in allowed_roles:
            raise HTTPException(
                status_code=403,
                detail="Invalid management role."
            )

        if database_role not in allowed_roles:
            raise HTTPException(
                status_code=403,
                detail=(
                    "This account is not authorized for "
                    "Management portal."
                )
            )

        if selected_role != database_role:
            raise HTTPException(
                status_code=403,
                detail=(
                    "Selected management role does not match "
                    "the account role."
                )
            )


# =========================================================
# GOOGLE LOGIN
# =========================================================
@app.post("/api/auth/google-login")
def google_login(data: dict):
    credential = data.get("id_token") or data.get("credential")
    portal = normalize_portal(data.get("portal"))
    selected_role = normalize_role(data.get("role"))

    if not credential:
        raise HTTPException(
            status_code=400,
            detail="Google ID token is required."
        )

    if not portal:
        raise HTTPException(
            status_code=400,
            detail="Invalid portal."
        )

    try:
        base_google_request = requests.Request()

        def google_request(
            url,
            method="GET",
            body=None,
            headers=None,
            **kwargs
        ):
            kwargs.pop("timeout", None)

            return base_google_request(
                url,
                method=method,
                body=body,
                headers=headers,
                timeout=8,
                **kwargs
            )

        google_user = id_token.verify_oauth2_token(
            credential,
            google_request,
            GOOGLE_CLIENT_ID
        )

    except Exception as e:
        print("GOOGLE TOKEN VERIFICATION ERROR:", e)

        raise HTTPException(
            status_code=401,
            detail="Invalid or expired Google ID token."
        )

    google_id = google_user.get("sub")
    email = google_user.get("email")
    name = google_user.get("name")

    if not google_id or not email:
        raise HTTPException(
            status_code=400,
            detail="Google account information is incomplete."
        )

    email = email.strip().lower()
    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            SELECT
                current_database() AS database_name,
                current_user AS database_user,
                current_schema() AS current_schema,
                current_setting('search_path') AS search_path,
                to_regclass('public.users')::text
                    AS public_users_table,
                to_regclass('public.oauth_users')::text
                    AS public_oauth_users_table
        """)

        db_info = cursor.fetchone()

        print(
            "GOOGLE LOGIN DB DIAGNOSTIC:",
            dict(db_info) if db_info else None
        )

        cursor.execute("""
            SELECT id, name, email, password_hash,
                   role, department_id, status
            FROM public.users
            WHERE LOWER(email) = LOWER(%s)
        """, (email,))

        user = cursor.fetchone()

        if not user:
            if portal == "management":
                raise HTTPException(
                    status_code=403,
                    detail=(
                        "Management access is unavailable for this "
                        "Google account. Ask an administrator to "
                        "assign a management role."
                    )
                )

            cursor.execute("""
                INSERT INTO public.users (
                    name, email, password_hash, role, status
                )
                VALUES (%s, %s, NULL, 'Employee', 'Active')
                RETURNING id, name, email, role,
                          department_id, status
            """, (name or "Employee", email))

            user = cursor.fetchone()

        database_role = normalize_database_role(user["role"])

        if str(user["status"]).strip().lower() != "active":
            raise HTTPException(
                status_code=403,
                detail="User account is inactive."
            )

        verify_portal_and_role(
            portal,
            selected_role,
            database_role
        )

        cursor.execute("""
            SELECT id
            FROM public.oauth_users
            WHERE LOWER(email) = LOWER(%s)
        """, (email,))

        oauth_user = cursor.fetchone()

        if oauth_user:
            cursor.execute("""
                UPDATE public.oauth_users
                SET user_id = %s,
                    google_id = %s,
                    name = %s,
                    portal = %s,
                    role = NULL,
                    status = %s,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = %s
            """, (
                user["id"],
                google_id,
                name or user["name"],
                portal,
                user["status"],
                oauth_user["id"]
            ))

        else:
            cursor.execute("""
                INSERT INTO public.oauth_users (
                    user_id, google_id, email, name,
                    portal, role, status
                )
                VALUES (%s, %s, %s, %s, %s, NULL, %s)
            """, (
                user["id"],
                google_id,
                email,
                name or user["name"],
                portal,
                user["status"]
            ))

        connection.commit()

        access_token = create_access_token(
            user["id"],
            user["email"],
            database_role,
            portal
        )

        return {
            "success": True,
            "message": "Google login successful.",
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": user["id"],
                "name": user["name"],
                "email": user["email"],
                "role": database_role,
                "department_id": user["department_id"],
                "status": user["status"]
            }
        }

    except HTTPException:
        connection.rollback()
        raise

    except Exception as e:
        connection.rollback()
        print("GOOGLE LOGIN DATABASE ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Google login failed."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# CREATE ASSET REQUEST
# =========================================================
@app.post("/api/requests")
def create_asset_request(
    data: AssetRequestCreate,
    authorization: str | None = Header(default=None)
):
    current = require_active_user(authorization)
    user = current["user"]

    if current["role"] not in {"EMPLOYEE", "ADMIN"}:
        raise HTTPException(
            status_code=403,
            detail="Only Employee accounts can create asset requests."
        )

    asset_id = data.asset_id.strip()
    asset_name = data.asset_name.strip()
    description = data.description.strip()

    if not asset_id or not asset_name or not description:
        raise HTTPException(
            status_code=400,
            detail=(
                "Asset ID, asset name and description are required."
            )
        )

    priority = data.priority.strip() if data.priority else "Normal"

    allowed_priorities = {
        "Normal", "Urgent", "Low", "Medium", "High"
    }

    if priority not in allowed_priorities:
        raise HTTPException(
            status_code=400,
            detail="Invalid priority."
        )

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            INSERT INTO public.asset_requests (
                request_code,
                user_id,
                employee_name,
                employee_email,
                department,
                asset_id,
                asset_name,
                asset_category,
                asset_brand,
                asset_model,
                priority,
                description,
                status
            )
            VALUES (
                'TEMP', %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, 'Pending'
            )
            RETURNING id
        """, (
            user["id"],
            user["name"],
            user["email"],
            data.department.strip() if data.department else None,
            asset_id,
            asset_name,
            data.asset_category.strip()
            if data.asset_category else None,
            data.asset_brand.strip()
            if data.asset_brand else None,
            data.asset_model.strip()
            if data.asset_model else None,
            priority,
            description
        ))

        created = cursor.fetchone()
        request_id = created["id"]
        request_code = f"REQ-{1000 + request_id}"

        cursor.execute("""
            UPDATE public.asset_requests
            SET request_code = %s
            WHERE id = %s
        """, (request_code, request_id))

        cursor.execute("""
            SELECT *
            FROM public.asset_requests
            WHERE id = %s
        """, (request_id,))

        request = cursor.fetchone()
        connection.commit()

        return {
            "success": True,
            "message": "Asset request submitted successfully.",
            "request": request
        }

    except Exception as e:
        connection.rollback()
        print("CREATE REQUEST ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to create asset request."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# GET ALL REQUESTS - MANAGER / ADMIN
# =========================================================
@app.get("/api/requests")
def get_all_requests(
    authorization: str | None = Header(default=None)
):
    require_request_manager(authorization)

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            SELECT *
            FROM public.asset_requests
            ORDER BY created_at DESC
        """)

        requests_data = cursor.fetchall()

        return {
            "success": True,
            "count": len(requests_data),
            "requests": requests_data
        }

    except Exception as e:
        print("GET ALL REQUESTS ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to load asset requests."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# GET MY REQUESTS - CURRENT USER ONLY
# =========================================================
@app.get("/api/requests/my")
def get_my_requests(
    authorization: str | None = Header(default=None)
):
    current = require_active_user(authorization)
    user = current["user"]

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            SELECT *
            FROM public.asset_requests
            WHERE user_id = %s
            ORDER BY created_at DESC
        """, (user["id"],))

        requests_data = cursor.fetchall()

        return {
            "success": True,
            "count": len(requests_data),
            "requests": requests_data
        }

    except Exception as e:
        print("GET MY REQUESTS ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to load your asset requests."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# GET SINGLE REQUEST
# =========================================================
@app.get("/api/requests/{request_id}")
def get_single_request(
    request_id: int,
    authorization: str | None = Header(default=None)
):
    current = require_active_user(authorization)
    user = current["user"]
    role = current["role"]

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            SELECT *
            FROM public.asset_requests
            WHERE id = %s
        """, (request_id,))

        request = cursor.fetchone()

        if not request:
            raise HTTPException(
                status_code=404,
                detail="Request not found."
            )

        if role == "EMPLOYEE":
            if request["user_id"] != user["id"]:
                raise HTTPException(
                    status_code=403,
                    detail="You are not allowed to view this request."
                )

        elif role not in {"ADMIN", "ASSET_MANAGER"}:
            raise HTTPException(
                status_code=403,
                detail="You are not authorized to view this request."
            )

        return {
            "success": True,
            "request": request
        }

    except HTTPException:
        raise

    except Exception as e:
        print("GET SINGLE REQUEST ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to load request."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# APPROVE / REJECT REQUEST + NOTIFICATION
# =========================================================
@app.patch("/api/requests/{request_id}/status")
def update_request_status(
    request_id: int,
    data: RequestStatusUpdate,
    authorization: str | None = Header(default=None)
):
    current = require_request_manager(authorization)
    manager = current["user"]

    status = data.status.strip().lower()

    if status in ["approved", "approve"]:
        new_status = "Approved"

    elif status in [
        "rejected", "reject", "not approved",
        "not_approved", "notapproved"
    ]:
        new_status = "Rejected"

    else:
        raise HTTPException(
            status_code=400,
            detail="Status must be Approved or Rejected."
        )

    rejection_reason = None

    if new_status == "Rejected":
        rejection_reason = (
            data.rejection_reason.strip()
            if data.rejection_reason
            else ""
        )

        if not rejection_reason:
            raise HTTPException(
                status_code=400,
                detail="Rejection reason is required."
            )

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            SELECT id, request_code, user_id, employee_name,
                   employee_email, asset_name, status
            FROM public.asset_requests
            WHERE id = %s
            FOR UPDATE
        """, (request_id,))

        request = cursor.fetchone()

        if not request:
            raise HTTPException(
                status_code=404,
                detail="Request not found."
            )

        if str(request["status"]).strip().lower() != "pending":
            raise HTTPException(
                status_code=409,
                detail="This request has already been reviewed."
            )

        cursor.execute("""
            UPDATE public.asset_requests
            SET status = %s,
                rejection_reason = %s,
                reviewed_at = CURRENT_TIMESTAMP,
                reviewed_by = %s,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = %s
            RETURNING *
        """, (
            new_status,
            rejection_reason,
            manager["id"],
            request_id
        ))

        updated_request = cursor.fetchone()

        if new_status == "Approved":
            title = "Asset Request Approved"
            message = (
                f"Your request {request['request_code']} for "
                f"{request['asset_name']} has been approved."
            )
            notification_type = "request_approved"

        else:
            title = "Asset Request Rejected"
            message = (
                f"Your request {request['request_code']} for "
                f"{request['asset_name']} has been rejected. "
                f"Reason: {rejection_reason}"
            )
            notification_type = "request_rejected"

        cursor.execute("""
            INSERT INTO public.notifications (
                user_id,
                title,
                message,
                notification_type,
                request_id
            )
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id, created_at
        """, (
            request["user_id"],
            title,
            message,
            notification_type,
            request_id
        ))

        notification = cursor.fetchone()
        connection.commit()

        print("REQUEST STATUS UPDATED:", new_status)
        print("REQUEST:", request["request_code"])
        print("NOTIFICATION ID:", notification["id"])

        return {
            "success": True,
            "message": (
                "Request approved and employee notified."
                if new_status == "Approved"
                else "Request rejected and employee notified."
            ),
            "request": updated_request,
            "notification_created": True
        }

    except HTTPException:
        connection.rollback()
        raise

    except Exception as e:
        connection.rollback()
        print("UPDATE REQUEST STATUS ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to update request status."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# REQUEST STATISTICS
# =========================================================
@app.get("/api/requests/stats")
def get_request_stats(
    authorization: str | None = Header(default=None)
):
    require_request_manager(authorization)

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            SELECT
                COUNT(*) AS total,
                COUNT(*) FILTER (
                    WHERE status = 'Pending'
                ) AS pending,
                COUNT(*) FILTER (
                    WHERE status = 'Approved'
                ) AS approved,
                COUNT(*) FILTER (
                    WHERE status = 'Rejected'
                ) AS rejected
            FROM public.asset_requests
        """)

        stats = cursor.fetchone()

        return {
            "success": True,
            "stats": {
                "total": stats["total"],
                "pending": stats["pending"],
                "approved": stats["approved"],
                "rejected": stats["rejected"]
            }
        }

    except Exception as e:
        print("REQUEST STATS ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to load request statistics."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# GET MY NOTIFICATIONS
# =========================================================
@app.get("/api/notifications/me")
def get_my_notifications(
    authorization: str | None = Header(default=None)
):
    current = require_active_user(authorization)
    user = current["user"]

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
        """, (user["id"],))

        notifications = cursor.fetchall()

        return {
            "success": True,
            "count": len(notifications),
            "notifications": notifications
        }

    except Exception as e:
        print("GET NOTIFICATIONS ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to load notifications."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# GET UNREAD NOTIFICATION COUNT
# =========================================================
@app.get("/api/notifications/unread-count")
def get_unread_notification_count(
    authorization: str | None = Header(default=None)
):
    current = require_active_user(authorization)
    user = current["user"]

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            SELECT COUNT(*) AS unread_count
            FROM public.notifications
            WHERE user_id = %s
              AND is_read = FALSE
        """, (user["id"],))

        result = cursor.fetchone()

        return {
            "success": True,
            "unread_count": result["unread_count"]
        }

    except Exception as e:
        print("UNREAD COUNT ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to load unread count."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# MARK ONE NOTIFICATION AS READ
# =========================================================
@app.patch("/api/notifications/{notification_id}/read")
def mark_notification_as_read(
    notification_id: int,
    authorization: str | None = Header(default=None)
):
    current = require_active_user(authorization)
    user = current["user"]

    connection = get_connection()
    cursor = connection.cursor(cursor_factory=RealDictCursor)

    try:
        cursor.execute("""
            UPDATE public.notifications
            SET is_read = TRUE
            WHERE id = %s
              AND user_id = %s
            RETURNING id, is_read
        """, (notification_id, user["id"]))

        notification = cursor.fetchone()

        if not notification:
            raise HTTPException(
                status_code=404,
                detail="Notification not found."
            )

        connection.commit()

        return {
            "success": True,
            "message": "Notification marked as read.",
            "notification": notification
        }

    except HTTPException:
        connection.rollback()
        raise

    except Exception as e:
        connection.rollback()
        print("MARK NOTIFICATION READ ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to mark notification as read."
        )

    finally:
        cursor.close()
        connection.close()


# =========================================================
# MARK ALL NOTIFICATIONS AS READ
# =========================================================
@app.patch("/api/notifications/read-all")
def mark_all_notifications_as_read(
    authorization: str | None = Header(default=None)
):
    current = require_active_user(authorization)
    user = current["user"]

    connection = get_connection()
    cursor = connection.cursor()

    try:
        cursor.execute("""
            UPDATE public.notifications
            SET is_read = TRUE
            WHERE user_id = %s
              AND is_read = FALSE
        """, (user["id"],))

        updated_count = cursor.rowcount
        connection.commit()

        return {
            "success": True,
            "message": "All notifications marked as read.",
            "updated_count": updated_count
        }

    except Exception as e:
        connection.rollback()
        print("MARK ALL NOTIFICATIONS READ ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to mark notifications as read."
        )

    finally:
        cursor.close()
        connection.close()