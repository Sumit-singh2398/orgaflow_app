from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

import psycopg2
from psycopg2.extras import RealDictCursor

from passlib.context import CryptContext

from google.oauth2 import id_token
from google.auth.transport import requests

from jose import jwt
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

JWT_EXPIRATION_MINUTES = 60 * 24


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
# NORMALIZE PORTAL
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
# ROOT
# =========================================================

@app.get("/")
def root():

    return {
        "message": "Orgaflow Backend is running",
        "status": "success"
    }


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

        password_hash = pwd_context.hash(password)

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
                detail="Invalid email or password."
            )

        password_hash = user.get("password_hash")

        if not password_hash:

            raise HTTPException(
                status_code=401,
                detail="This account uses Google login."
            )

        if not pwd_context.verify(
            password,
            password_hash
        ):

            raise HTTPException(
                status_code=401,
                detail="Invalid email or password."
            )

        if str(user["status"]).lower() != "active":

            raise HTTPException(
                status_code=403,
                detail="User account is inactive."
            )

        database_role = normalize_database_role(
            user["role"]
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
# VERIFY PORTAL + ROLE
# =========================================================

def verify_portal_and_role(
    portal,
    selected_role,
    database_role
):

    portal = normalize_portal(portal)

    selected_role = normalize_role(
        selected_role
    )

    database_role = normalize_database_role(
        database_role
    )

    # -----------------------------------------------------
    # INVALID PORTAL
    # -----------------------------------------------------

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
                detail="This account is not allowed to access Employee portal."
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

        # Selected role is required
        if not selected_role:

            raise HTTPException(
                status_code=400,
                detail="Management role is required."
            )

        # Selected role must be a valid management role
        if selected_role not in allowed_management_roles:

            raise HTTPException(
                status_code=403,
                detail="Invalid management role."
            )

        # Database role must be a management role
        if database_role not in allowed_management_roles:

            raise HTTPException(
                status_code=403,
                detail="This account is not authorized for Management portal."
            )

        # Selected role must match actual DB role
        if selected_role != database_role:

            raise HTTPException(
                status_code=403,
                detail=(
                    "Selected management role does not match "
                    "the role assigned to this account."
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

    # IMPORTANT:
    # Flutter currently sends "id_token".
    #
    # "credential" is also supported for compatibility.
    #
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

    # -----------------------------------------------------
    # TOKEN CHECK
    # -----------------------------------------------------

    if not credential:

        print(
            "ERROR: Google ID token missing"
        )

        raise HTTPException(
            status_code=400,
            detail="Google ID token is required."
        )

    # -----------------------------------------------------
    # PORTAL CHECK
    # -----------------------------------------------------

    if not portal:

        print(
            "ERROR: Invalid or missing portal"
        )

        raise HTTPException(
            status_code=400,
            detail="Invalid portal."
        )

    # -----------------------------------------------------
    # VERIFY GOOGLE TOKEN
    # -----------------------------------------------------

    try:

        google_user = id_token.verify_oauth2_token(
            credential,
            requests.Request(),
            GOOGLE_CLIENT_ID
        )

    except ValueError as e:

        print(
            "GOOGLE TOKEN VERIFICATION ERROR:",
            e
        )

        raise HTTPException(
            status_code=401,
            detail="Invalid or expired Google ID token."
        )

    except Exception as e:

        print(
            "GOOGLE TOKEN ERROR:",
            e
        )

        raise HTTPException(
            status_code=401,
            detail="Google authentication failed."
        )

    # -----------------------------------------------------
    # GOOGLE USER DATA
    # -----------------------------------------------------

    google_id = google_user.get("sub")
    email = google_user.get("email")
    name = google_user.get("name")

    if not google_id or not email:

        raise HTTPException(
            status_code=400,
            detail="Google account information is incomplete."
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

    # =====================================================
    # DATABASE
    # =====================================================

    connection = get_connection()

    cursor = connection.cursor(
        cursor_factory=RealDictCursor
    )

    try:

        # -------------------------------------------------
        # FIND EXISTING USER
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
        # USER DOES NOT EXIST
        # -------------------------------------------------

        if not user:

            print(
                "USER NOT FOUND IN USERS TABLE"
            )

            # New Google users can enter Employee portal.
            #
            # But management users must first be
            # provisioned by an administrator.

            if portal == "management":

                raise HTTPException(
                    status_code=403,
                    detail=(
                        "Management access is not available "
                        "for this Google account. "
                        "Ask an administrator to provision "
                        "your management role first."
                    )
                )

            # -------------------------------------------------
            # CREATE EMPLOYEE USER
            # -------------------------------------------------

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
        # USER EXISTS
        # -------------------------------------------------

        database_role_raw = user.get("role")

        database_role = normalize_database_role(
            database_role_raw
        )

        print(
            "DATABASE ROLE RAW:",
            database_role_raw
        )

        print(
            "DATABASE ROLE NORMALIZED:",
            database_role
        )

        print(
            "USER ID:",
            user["id"]
        )

        print(
            "STATUS:",
            user["status"]
        )

        # -------------------------------------------------
        # STATUS CHECK
        # -------------------------------------------------

        if str(user["status"]).lower() != "active":

            raise HTTPException(
                status_code=403,
                detail="User account is inactive."
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
        # FIND OAUTH USER
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
            WHERE
                LOWER(email) = LOWER(%s)
            """,
            (email,)
        )

        oauth_user = cursor.fetchone()

        # -------------------------------------------------
        # CREATE / UPDATE OAUTH MAPPING
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
        # CREATE JWT
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

        # -------------------------------------------------
        # RESPONSE
        # -------------------------------------------------

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