from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware

import psycopg2
from psycopg2.extras import RealDictCursor

from passlib.context import CryptContext

from google.oauth2 import id_token
from google.auth.transport import requests

from jose import jwt, JWTError

from pydantic import BaseModel

from datetime import datetime, timedelta


# =========================================================
# APP
# =========================================================

app = FastAPI(
    title="Orgaflow Backend",
    version="1.0.0"
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
# DATABASE CONFIG
# =========================================================

DB_HOST = "localhost"
DB_PORT = 5432
DB_NAME = "orgaflow_db"
DB_USER = "postgres"
DB_PASSWORD = "mehra"


# =========================================================
# GOOGLE CONFIG
# =========================================================

GOOGLE_CLIENT_ID = (
    "449981088129-fptar4p18jkmsgk6avhigqintmv0qha3"
    ".apps.googleusercontent.com"
)


# =========================================================
# JWT CONFIG
# =========================================================

JWT_SECRET = "orgaflow_super_secret_key_change_later"

JWT_ALGORITHM = "HS256"

JWT_EXPIRATION_MINUTES = 60*24*7


# =========================================================
# PASSWORD HASHING
# =========================================================

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)


# =========================================================
# DATABASE CONNECTION
# =========================================================

def get_connection():

    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
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

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS asset_requests (

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
            """
        )

        # -------------------------------------------------
        # INDEXES
        # -------------------------------------------------

        cursor.execute(
            """
            CREATE INDEX IF NOT EXISTS
            idx_asset_requests_user_id
            ON asset_requests(user_id)
            """
        )

        cursor.execute(
            """
            CREATE INDEX IF NOT EXISTS
            idx_asset_requests_status
            ON asset_requests(status)
            """
        )

        cursor.execute(
            """
            CREATE INDEX IF NOT EXISTS
            idx_asset_requests_created_at
            ON asset_requests(created_at DESC)
            """
        )

        connection.commit()

        print("========================================")
        print("ASSET REQUEST TABLE READY")
        print("========================================")

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
# STARTUP
# =========================================================

@app.on_event("startup")
def startup_event():

    print()
    print("========================================")
    print("ORGAFLOW BACKEND STARTING")
    print("========================================")

    try:

        create_request_table()

    except Exception as e:

        print("DATABASE INITIALIZATION FAILED:", e)

        print(
            "Please check PostgreSQL and orgaflow_db."
        )

    print("========================================")
    print()


# =========================================================
# NORMALIZE PORTAL
# =========================================================

def normalize_portal(portal):

    if portal is None:
        return None

    value = str(portal).strip().lower()

    if value == "employee":
        return "employee"

    if value in [
        "management",
        "manager",
        "admin"
    ]:
        return "management"

    return None


# =========================================================
# NORMALIZE FRONTEND ROLE
# =========================================================

def normalize_role(role):

    if role is None:
        return None

    value = str(role).strip()

    compact = (
        value
        .replace(" ", "")
        .replace("_", "")
        .lower()
    )

    if compact == "admin":
        return "ADMIN"

    if compact == "assetmanager":
        return "ASSET_MANAGER"

    if compact == "departmenthead":
        return "DEPARTMENT_HEAD"

    if compact == "employee":
        return "EMPLOYEE"

    return value.upper()


# =========================================================
# NORMALIZE DATABASE ROLE
# =========================================================

def normalize_database_role(role):

    if role is None:
        return None

    value = str(role).strip()

    compact = (
        value
        .replace(" ", "")
        .replace("_", "")
        .lower()
    )

    if compact == "employee":
        return "EMPLOYEE"

    if compact == "departmenthead":
        return "DEPARTMENT_HEAD"

    if compact == "assetmanager":
        return "ASSET_MANAGER"

    if compact == "admin":
        return "ADMIN"

    return value.upper()


# =========================================================
# CREATE JWT
# =========================================================

def create_access_token(
    user_id,
    email,
    role,
    portal
):

    expire = datetime.utcnow() + timedelta(
        minutes=JWT_EXPIRATION_MINUTES
    )

    payload = {
        "user_id": user_id,
        "email": email,
        "role": role,
        "portal": portal,
        "exp": expire
    }

    token = jwt.encode(
        payload,
        JWT_SECRET,
        algorithm=JWT_ALGORITHM
    )

    return token


# =========================================================
# GET CURRENT USER FROM JWT
# =========================================================

def get_current_user(
    authorization: str | None
):

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

    token = authorization.replace(
        "Bearer ",
        "",
        1
    ).strip()

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

        email = payload.get("email")

        role = payload.get("role")

        portal = payload.get("portal")

        if not user_id:

            raise HTTPException(
                status_code=401,
                detail="Invalid token."
            )

        return {
            "user_id": user_id,
            "email": email,
            "role": role,
            "portal": portal
        }

    except JWTError:

        raise HTTPException(
            status_code=401,
            detail="Invalid or expired token."
        )


# =========================================================
# GET USER FROM DATABASE
# =========================================================

def get_database_user(user_id):

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        cursor.execute(
            """
            SELECT
                id,
                name,
                email,
                role,
                department_id,
                status
            FROM users
            WHERE id = %s
            """,
            (user_id,)
        )

        user = cursor.fetchone()

        return user

    finally:

        cursor.close()
        connection.close()


# =========================================================
# REQUIRE ACTIVE USER
# =========================================================

def require_active_user(
    authorization: str | None
):

    token_user = get_current_user(
        authorization
    )

    user = get_database_user(
        token_user["user_id"]
    )

    if not user:

        raise HTTPException(
            status_code=401,
            detail="User account not found."
        )

    if str(user["status"]).lower() != "active":

        raise HTTPException(
            status_code=403,
            detail="User account is inactive."
        )

    database_role = normalize_database_role(
        user["role"]
    )

    return {
        "token": token_user,
        "user": user,
        "role": database_role
    }


# =========================================================
# REQUIRE REQUEST MANAGEMENT ACCESS
# =========================================================

def require_request_manager(
    authorization: str | None
):

    current = require_active_user(
        authorization
    )

    role = current["role"]

    allowed_roles = {
        "ADMIN",
        "ASSET_MANAGER"
    }

    if role not in allowed_roles:

        raise HTTPException(
            status_code=403,
            detail=(
                "Only Admin or Asset Manager "
                "can manage asset requests."
            )
        )

    return current


# =========================================================
# REQUEST CREATE MODEL
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


# =========================================================
# REQUEST STATUS UPDATE MODEL
# =========================================================

class RequestStatusUpdate(BaseModel):

    status: str

    rejection_reason: str | None = None


# =========================================================
# ROOT
# =========================================================

@app.get("/")
def root():

    return {
        "message": "Orgaflow Backend is running",
        "status": "success"
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

        cursor.execute(
            "SELECT 1"
        )

        cursor.fetchone()

        return {
            "success": True,
            "message": "Backend and database are connected."
        }

    except Exception as e:

        print("HEALTH CHECK ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Database connection failed."
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

    department_id = data.get(
        "department_id"
    )

    if not name or not email or not password:

        raise HTTPException(
            status_code=400,
            detail=(
                "Name, email and password "
                "are required."
            )
        )

    email = email.strip().lower()

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        cursor.execute(
            """
            SELECT id
            FROM users
            WHERE LOWER(email) = LOWER(%s)
            """,
            (email,)
        )

        existing_user = cursor.fetchone()

        if existing_user:

            raise HTTPException(
                status_code=400,
                detail="User already exists."
            )

        password_hash = pwd_context.hash(
            password
        )

        cursor.execute(
            """
            INSERT INTO users
            (
                name,
                email,
                password_hash,
                role,
                department_id,
                status
            )
            VALUES
            (
                %s,
                %s,
                %s,
                'Employee',
                %s,
                'Active'
            )
            RETURNING
                id,
                name,
                email,
                role,
                department_id,
                status
            """,
            (
                name,
                email,
                password_hash,
                department_id
            )
        )

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

        print(
            "SIGNUP ERROR:",
            e
        )

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
            detail=(
                "Email and password "
                "are required."
            )
        )

    email = email.strip().lower()

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        cursor.execute(
            """
            SELECT
                id,
                name,
                email,
                password_hash,
                role,
                department_id,
                status
            FROM users
            WHERE LOWER(email) = LOWER(%s)
            """,
            (email,)
        )

        user = cursor.fetchone()

        if not user:

            raise HTTPException(
                status_code=401,
                detail=(
                    "Invalid email or password."
                )
            )

        password_hash = user.get(
            "password_hash"
        )

        if not password_hash:

            raise HTTPException(
                status_code=401,
                detail=(
                    "This account uses "
                    "Google login."
                )
            )

        if not pwd_context.verify(
            password,
            password_hash
        ):

            raise HTTPException(
                status_code=401,
                detail=(
                    "Invalid email or password."
                )
            )

        if str(
            user["status"]
        ).lower() != "active":

            raise HTTPException(
                status_code=403,
                detail=(
                    "User account is inactive."
                )
            )

        database_role = (
            normalize_database_role(
                user["role"]
            )
        )

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
                "department_id": user[
                    "department_id"
                ],
                "status": user["status"]
            }
        }

    except HTTPException:

        raise

    except Exception as e:

        print(
            "LOGIN ERROR:",
            e
        )

        raise HTTPException(
            status_code=500,
            detail="Login failed."
        )

    finally:

        cursor.close()

        connection.close()


# =========================================================
# VERIFY PORTAL + ROLE
# =========================================================

def verify_portal_and_role(
    portal,
    selected_role,
    database_role
):

    portal = normalize_portal(
        portal
    )

    selected_role = normalize_role(
        selected_role
    )

    database_role = (
        normalize_database_role(
            database_role
        )
    )

    if not portal:

        raise HTTPException(
            status_code=400,
            detail="Invalid portal."
        )

    # -----------------------------------------------------
    # EMPLOYEE PORTAL
    # -----------------------------------------------------

    if portal == "employee":

        allowed_roles = {
            "EMPLOYEE",
            "ADMIN"
        }

        if database_role not in allowed_roles:

            raise HTTPException(
                status_code=403,
                detail=(
                    "This account is not allowed "
                    "to access Employee portal."
                )
            )

        return

    # -----------------------------------------------------
    # MANAGEMENT PORTAL
    # -----------------------------------------------------

    if portal == "management":

        allowed_management_roles = {
            "ADMIN",
            "ASSET_MANAGER",
            "DEPARTMENT_HEAD"
        }

        if not selected_role:

            raise HTTPException(
                status_code=400,
                detail=(
                    "Management role is required."
                )
            )

        if (
            selected_role
            not in allowed_management_roles
        ):

            raise HTTPException(
                status_code=403,
                detail=(
                    "Invalid management role."
                )
            )

        if (
            database_role
            not in allowed_management_roles
        ):

            raise HTTPException(
                status_code=403,
                detail=(
                    "This account is not authorized "
                    "for Management portal."
                )
            )

        if selected_role != database_role:

            raise HTTPException(
                status_code=403,
                detail=(
                    "Selected management role does "
                    "not match the role assigned "
                    "to this account."
                )
            )

        return


# =========================================================
# GOOGLE LOGIN
# =========================================================

@app.post("/api/auth/google-login")
def google_login(data: dict):

    print()
    print("========================================")
    print("GOOGLE LOGIN REQUEST RECEIVED")
    print("RAW REQUEST DATA:", data)
    print("========================================")

    credential = (
        data.get("id_token")
        or data.get("credential")
    )

    portal = normalize_portal(
        data.get("portal")
    )

    selected_role = normalize_role(
        data.get("role")
    )

    print(
        "CREDENTIAL EXISTS:",
        bool(credential)
    )

    print(
        "PORTAL:",
        portal
    )

    print(
        "SELECTED ROLE:",
        selected_role
    )

    if not credential:

        raise HTTPException(
            status_code=400,
            detail=(
                "Google ID token is required."
            )
        )

    if not portal:

        raise HTTPException(
            status_code=400,
            detail="Invalid portal."
        )

    # -----------------------------------------------------
    # VERIFY GOOGLE TOKEN
    # -----------------------------------------------------

    try:

        google_user = (
            id_token.verify_oauth2_token(
                credential,
                requests.Request(),
                GOOGLE_CLIENT_ID
            )
        )

    except ValueError as e:

        print(
            "GOOGLE TOKEN VERIFICATION ERROR:",
            e
        )

        raise HTTPException(
            status_code=401,
            detail=(
                "Invalid or expired "
                "Google ID token."
            )
        )

    except Exception as e:

        print(
            "GOOGLE TOKEN ERROR:",
            e
        )

        raise HTTPException(
            status_code=401,
            detail=(
                "Google authentication failed."
            )
        )

    # -----------------------------------------------------
    # GOOGLE USER DATA
    # -----------------------------------------------------

    google_id = google_user.get(
        "sub"
    )

    email = google_user.get(
        "email"
    )

    name = google_user.get(
        "name"
    )

    if not google_id or not email:

        raise HTTPException(
            status_code=400,
            detail=(
                "Google account information "
                "is incomplete."
            )
        )

    email = email.strip().lower()

    print(
        "GOOGLE USER:",
        email
    )

    print(
        "GOOGLE NAME:",
        name
    )

    print(
        "GOOGLE ID:",
        google_id
    )

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        # -------------------------------------------------
        # FIND USER
        # -------------------------------------------------

        cursor.execute(
            """
            SELECT
                id,
                name,
                email,
                password_hash,
                role,
                department_id,
                status
            FROM users
            WHERE LOWER(email) = LOWER(%s)
            """,
            (email,)
        )

        user = cursor.fetchone()

        # -------------------------------------------------
        # NEW USER
        # -------------------------------------------------

        if not user:

            print(
                "USER NOT FOUND IN USERS TABLE"
            )

            if portal == "management":

                raise HTTPException(
                    status_code=403,
                    detail=(
                        "Management access is not "
                        "available for this Google "
                        "account. Ask an administrator "
                        "to provision your management "
                        "role first."
                    )
                )

            cursor.execute(
                """
                INSERT INTO users
                (
                    name,
                    email,
                    password_hash,
                    role,
                    status
                )
                VALUES
                (
                    %s,
                    %s,
                    NULL,
                    'Employee',
                    'Active'
                )
                RETURNING
                    id,
                    name,
                    email,
                    role,
                    department_id,
                    status
                """,
                (
                    name or "Employee",
                    email
                )
            )

            user = cursor.fetchone()

            connection.commit()

            print(
                "NEW EMPLOYEE USER CREATED"
            )

        # -------------------------------------------------
        # ROLE
        # -------------------------------------------------

        database_role_raw = user.get(
            "role"
        )

        database_role = (
            normalize_database_role(
                database_role_raw
            )
        )

        # -------------------------------------------------
        # STATUS
        # -------------------------------------------------

        if str(
            user["status"]
        ).lower() != "active":

            raise HTTPException(
                status_code=403,
                detail=(
                    "User account is inactive."
                )
            )

        # -------------------------------------------------
        # PORTAL + ROLE AUTHORIZATION
        # -------------------------------------------------

        verify_portal_and_role(
            portal,
            selected_role,
            database_role
        )

        # -------------------------------------------------
        # OAUTH USER
        # -------------------------------------------------

        cursor.execute(
            """
            SELECT
                id,
                user_id,
                google_id,
                email,
                name,
                portal,
                role,
                status
            FROM oauth_users
            WHERE LOWER(email) = LOWER(%s)
            """,
            (email,)
        )

        oauth_user = cursor.fetchone()

        # -------------------------------------------------
        # UPDATE OAUTH
        # -------------------------------------------------

        if oauth_user:

            cursor.execute(
                """
                UPDATE oauth_users
                SET
                    user_id = %s,
                    google_id = %s,
                    name = %s,
                    portal = %s,
                    role = NULL,
                    status = %s
                WHERE id = %s
                """,
                (
                    user["id"],
                    google_id,
                    name or user["name"],
                    portal,
                    user["status"],
                    oauth_user["id"]
                )
            )

        # -------------------------------------------------
        # CREATE OAUTH
        # -------------------------------------------------

        else:

            cursor.execute(
                """
                INSERT INTO oauth_users
                (
                    user_id,
                    google_id,
                    email,
                    name,
                    portal,
                    role,
                    status
                )
                VALUES
                (
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    NULL,
                    %s
                )
                """,
                (
                    user["id"],
                    google_id,
                    email,
                    name or user["name"],
                    portal,
                    user["status"]
                )
            )

        connection.commit()

        # -------------------------------------------------
        # JWT
        # -------------------------------------------------

        access_token = create_access_token(
            user["id"],
            user["email"],
            database_role,
            portal
        )

        print()
        print("========================================")
        print("GOOGLE LOGIN SUCCESS")
        print("EMAIL:", email)
        print("PORTAL:", portal)
        print("ROLE:", database_role)
        print("USER ID:", user["id"])
        print("========================================")
        print()

        return {
            "success": True,
            "message": (
                "Google login successful."
            ),
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": user["id"],
                "name": user["name"],
                "email": user["email"],
                "role": database_role,
                "department_id": user[
                    "department_id"
                ],
                "status": user["status"],
                "portal": portal
            }
        }

    except HTTPException:

        connection.rollback()

        raise

    except Exception as e:

        connection.rollback()

        print()
        print("========================================")
        print("GOOGLE LOGIN DATABASE ERROR")
        print("ERROR:", e)
        print("========================================")
        print()

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
#
# Employee selects asset
#       ↓
# Flutter POST /api/requests
#       ↓
# JWT identifies employee
#       ↓
# PostgreSQL
#       ↓
# Pending
#
# =========================================================

@app.post("/api/requests")
def create_asset_request(
    data: AssetRequestCreate,
    authorization: str | None = Header(
        default=None
    )
):

    current = require_active_user(
        authorization
    )

    user = current["user"]

    database_role = current["role"]

    # -----------------------------------------------------
    # ONLY EMPLOYEE / ADMIN CAN CREATE REQUEST
    # -----------------------------------------------------

    allowed_roles = {
        "EMPLOYEE",
        "ADMIN"
    }

    if database_role not in allowed_roles:

        raise HTTPException(
            status_code=403,
            detail=(
                "Only Employee accounts can "
                "create asset requests."
            )
        )

    # -----------------------------------------------------
    # VALIDATE ASSET
    # -----------------------------------------------------

    asset_id = data.asset_id.strip()

    asset_name = data.asset_name.strip()

    description = data.description.strip()

    if not asset_id:

        raise HTTPException(
            status_code=400,
            detail="Asset ID is required."
        )

    if not asset_name:

        raise HTTPException(
            status_code=400,
            detail="Asset name is required."
        )

    if not description:

        raise HTTPException(
            status_code=400,
            detail=(
                "Request description is required."
            )
        )

    # -----------------------------------------------------
    # PRIORITY
    # -----------------------------------------------------

    priority = (
        data.priority.strip()
        if data.priority
        else "Normal"
    )

    allowed_priorities = {
        "Normal",
        "Urgent",
        "Low",
        "Medium",
        "High"
    }

    if priority not in allowed_priorities:

        raise HTTPException(
            status_code=400,
            detail="Invalid priority."
        )

    # -----------------------------------------------------
    # DATABASE
    # -----------------------------------------------------

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        # -------------------------------------------------
        # INSERT REQUEST
        # -------------------------------------------------

        cursor.execute(
            """
            INSERT INTO asset_requests
            (
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
            VALUES
            (
                'TEMP',
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                'Pending'
            )
            RETURNING
                id,
                created_at,
                updated_at
            """,
            (
                user["id"],
                user["name"],
                user["email"],
                data.department.strip()
                if data.department
                else None,
                asset_id,
                asset_name,
                data.asset_category.strip()
                if data.asset_category
                else None,
                data.asset_brand.strip()
                if data.asset_brand
                else None,
                data.asset_model.strip()
                if data.asset_model
                else None,
                priority,
                description
            )
        )

        created = cursor.fetchone()

        request_id = created["id"]

        # -------------------------------------------------
        # CREATE REAL REQUEST CODE
        # -------------------------------------------------

        request_code = (
            f"REQ-{1000 + request_id}"
        )

        cursor.execute(
            """
            UPDATE asset_requests
            SET request_code = %s
            WHERE id = %s
            """,
            (
                request_code,
                request_id
            )
        )

        connection.commit()

        # -------------------------------------------------
        # GET COMPLETE REQUEST
        # -------------------------------------------------

        cursor.execute(
            """
            SELECT
                id,
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
                status,
                rejection_reason,
                created_at,
                updated_at,
                reviewed_at,
                reviewed_by
            FROM asset_requests
            WHERE id = %s
            """,
            (request_id,)
        )

        request = cursor.fetchone()

        print()
        print("========================================")
        print("ASSET REQUEST CREATED")
        print("REQUEST:", request_code)
        print("EMPLOYEE:", user["email"])
        print("ASSET:", asset_name)
        print("STATUS: Pending")
        print("========================================")
        print()

        return {
            "success": True,
            "message": (
                "Asset request submitted successfully."
            ),
            "request": request
        }

    except Exception as e:

        connection.rollback()

        print(
            "CREATE REQUEST ERROR:",
            e
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Unable to create asset request."
            )
        )

    finally:

        cursor.close()

        connection.close()


# =========================================================
# GET ALL REQUESTS
# =========================================================
#
# Asset Manager / Admin only
#
# =========================================================

@app.get("/api/requests")
def get_all_requests(
    authorization: str | None = Header(
        default=None
    )
):

    require_request_manager(
        authorization
    )

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        cursor.execute(
            """
            SELECT
                id,
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
                status,
                rejection_reason,
                created_at,
                updated_at,
                reviewed_at,
                reviewed_by
            FROM asset_requests
            ORDER BY created_at DESC
            """
        )

        requests_data = cursor.fetchall()

        return {
            "success": True,
            "count": len(requests_data),
            "requests": requests_data
        }

    except Exception as e:

        print(
            "GET ALL REQUESTS ERROR:",
            e
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Unable to load asset requests."
            )
        )

    finally:

        cursor.close()

        connection.close()


# =========================================================
# GET MY REQUESTS
# =========================================================
#
# Employee can ONLY see requests belonging
# to their own user_id.
#
# =========================================================

@app.get("/api/requests/my")
def get_my_requests(
    authorization: str | None = Header(
        default=None
    )
):

    current = require_active_user(
        authorization
    )

    user = current["user"]

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        cursor.execute(
            """
            SELECT
                id,
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
                status,
                rejection_reason,
                created_at,
                updated_at,
                reviewed_at,
                reviewed_by
            FROM asset_requests
            WHERE user_id = %s
            ORDER BY created_at DESC
            """,
            (user["id"],)
        )

        requests_data = cursor.fetchall()

        return {
            "success": True,
            "count": len(requests_data),
            "requests": requests_data
        }

    except Exception as e:

        print(
            "GET MY REQUESTS ERROR:",
            e
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Unable to load your requests."
            )
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
    authorization: str | None = Header(
        default=None
    )
):

    current = require_active_user(
        authorization
    )

    user = current["user"]

    role = current["role"]

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        cursor.execute(
            """
            SELECT
                id,
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
                status,
                rejection_reason,
                created_at,
                updated_at,
                reviewed_at,
                reviewed_by
            FROM asset_requests
            WHERE id = %s
            """,
            (request_id,)
        )

        request = cursor.fetchone()

        if not request:

            raise HTTPException(
                status_code=404,
                detail="Request not found."
            )

        # -------------------------------------------------
        # EMPLOYEE CAN ONLY SEE OWN REQUEST
        # -------------------------------------------------

        if role == "EMPLOYEE":

            if request["user_id"] != user["id"]:

                raise HTTPException(
                    status_code=403,
                    detail=(
                        "You are not allowed "
                        "to view this request."
                    )
                )

        # -------------------------------------------------
        # MANAGEMENT CAN SEE ALL
        # -------------------------------------------------

        elif role not in {
            "ADMIN",
            "ASSET_MANAGER"
        }:

            raise HTTPException(
                status_code=403,
                detail=(
                    "You are not authorized "
                    "to view this request."
                )
            )

        return {
            "success": True,
            "request": request
        }

    except HTTPException:

        raise

    except Exception as e:

        print(
            "GET SINGLE REQUEST ERROR:",
            e
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Unable to load request."
            )
        )

    finally:

        cursor.close()

        connection.close()


# =========================================================
# APPROVE / REJECT REQUEST
# =========================================================
#
# ONLY ADMIN / ASSET_MANAGER
#
# Pending -> Approved
#
# Pending -> Rejected
#
# Rejected requires rejection_reason
#
# Already reviewed requests cannot be changed.
#
# =========================================================

@app.patch(
    "/api/requests/{request_id}/status"
)
def update_request_status(
    request_id: int,
    data: RequestStatusUpdate,
    authorization: str | None = Header(
        default=None
    )
):

    current = require_request_manager(
        authorization
    )

    manager = current["user"]

    # -----------------------------------------------------
    # NORMALIZE STATUS
    # -----------------------------------------------------

    status = (
        data.status
        .strip()
        .lower()
    )

    if status in [
        "approved",
        "approve"
    ]:

        new_status = "Approved"

    elif status in [
        "rejected",
        "reject",
        "not approved",
        "not_approved",
        "notapproved"
    ]:

        new_status = "Rejected"

    else:

        raise HTTPException(
            status_code=400,
            detail=(
                "Status must be Approved "
                "or Rejected."
            )
        )

    # -----------------------------------------------------
    # REJECTION REASON
    # -----------------------------------------------------

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
                detail=(
                    "Rejection reason is required "
                    "when a request is not approved."
                )
            )

    # -----------------------------------------------------
    # DATABASE
    # -----------------------------------------------------

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        # -------------------------------------------------
        # FIND REQUEST
        # -------------------------------------------------

        cursor.execute(
            """
            SELECT
                id,
                request_code,
                user_id,
                employee_name,
                employee_email,
                asset_name,
                status
            FROM asset_requests
            WHERE id = %s
            FOR UPDATE
            """,
            (request_id,)
        )

        request = cursor.fetchone()

        if not request:

            raise HTTPException(
                status_code=404,
                detail="Request not found."
            )

        # -------------------------------------------------
        # ONLY PENDING CAN BE REVIEWED
        # -------------------------------------------------

        current_status = (
            str(
                request["status"]
            ).strip().lower()
        )

        if current_status != "pending":

            raise HTTPException(
                status_code=409,
                detail=(
                    "This request has already "
                    "been reviewed and cannot "
                    "be changed again."
                )
            )

        # -------------------------------------------------
        # UPDATE
        # -------------------------------------------------

        cursor.execute(
            """
            UPDATE asset_requests
            SET
                status = %s,
                rejection_reason = %s,
                reviewed_at = CURRENT_TIMESTAMP,
                reviewed_by = %s,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = %s
            RETURNING
                id,
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
                status,
                rejection_reason,
                created_at,
                updated_at,
                reviewed_at,
                reviewed_by
            """,
            (
                new_status,
                rejection_reason,
                manager["id"],
                request_id
            )
        )

        updated_request = cursor.fetchone()

        connection.commit()

        print()
        print("========================================")
        print("REQUEST STATUS UPDATED")
        print("REQUEST:", request["request_code"])
        print("EMPLOYEE:", request["employee_email"])
        print("ASSET:", request["asset_name"])
        print("NEW STATUS:", new_status)
        print("REVIEWED BY:", manager["email"])

        if rejection_reason:
            print(
                "REJECTION REASON:",
                rejection_reason
            )

        print("========================================")
        print()

        return {
            "success": True,
            "message": (
                "Request approved successfully."
                if new_status == "Approved"
                else
                "Request marked as not approved."
            ),
            "request": updated_request
        }

    except HTTPException:

        connection.rollback()

        raise

    except Exception as e:

        connection.rollback()

        print(
            "UPDATE REQUEST STATUS ERROR:",
            e
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Unable to update request status."
            )
        )

    finally:

        cursor.close()

        connection.close()


# =========================================================
# REQUEST STATISTICS
# =========================================================
#
# Useful for Asset Management dashboard.
#
# =========================================================

@app.get("/api/requests/stats")
def get_request_stats(
    authorization: str | None = Header(
        default=None
    )
):

    require_request_manager(
        authorization
    )

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        cursor.execute(
            """
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
            FROM asset_requests
            """
        )

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

        print(
            "REQUEST STATS ERROR:",
            e
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Unable to load request statistics."
            )
        )

    finally:

        cursor.close()

        connection.close()