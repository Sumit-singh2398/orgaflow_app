from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, Field
from passlib.context import CryptContext

import psycopg2
from psycopg2.extras import RealDictCursor

from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

import re


# ============================================================
# APP
# ============================================================

app = FastAPI(
    title="Orgaflow API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# GOOGLE CONFIGURATION
# ============================================================

GOOGLE_CLIENT_ID = (
    "449981088129-fptar4p18jkmsgk6avhigqintmv0qha3.apps.googleusercontent.com"
)


# ============================================================
# PASSWORD HASHING
# ============================================================
#
# IMPORTANT:
# This is bcrypt password hashing.
# It is NOT JWT.
#
# Signup:
# password -> bcrypt hash -> database
#
# Login:
# entered password + database hash -> verify
#

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)


# ============================================================
# DATABASE
# ============================================================

def get_db_connection():


    return psycopg2.connect(
        host="localhost",
        database="orgaflow_db",
        user="postgres",
        password="mehra",
        cursor_factory=RealDictCursor
    )


# ============================================================
# REQUEST MODELS
# ============================================================

class SignupRequest(BaseModel):

    name: str = Field(
        ...,
        min_length=2,
        max_length=100
    )

    email: EmailStr

    phone: str = Field(
        ...,
        min_length=10,
        max_length=15
    )

    password: str = Field(
        ...,
        min_length=6,
        max_length=100
    )


class LoginRequest(BaseModel):

    email: EmailStr

    password: str

    portal: str

    # Only required for Management Portal
    role: str | None = None


class GoogleLoginRequest(BaseModel):

    id_token: str

    portal: str

    # Only required for Management Portal
    role: str | None = None


# ============================================================
# VALID PORTALS
# ============================================================

VALID_PORTALS = {
    "employee",
    "management"
}


# ============================================================
# VALID MANAGEMENT ROLES
# ============================================================

VALID_MANAGEMENT_ROLES = {
    "ADMIN",
    "ASSET_MANAGER",
    "DEPARTMENT_HEAD"
}


# ============================================================
# PORTAL NORMALIZATION
# ============================================================

def normalize_portal(portal: str) -> str:

    if not portal:

        raise HTTPException(
            status_code=400,
            detail="Portal is required."
        )

    normalized = portal.strip().lower()

    if normalized not in VALID_PORTALS:

        raise HTTPException(
            status_code=400,
            detail=(
                "Invalid portal. "
                "Use Employee or Management."
            )
        )

    return normalized


# ============================================================
# ROLE NORMALIZATION
# ============================================================

def normalize_role(
    role: str | None
) -> str | None:

    if role is None:
        return None

    normalized = (
        role
        .strip()
        .upper()
        .replace("-", "_")
        .replace(" ", "_")
    )

    if normalized not in VALID_MANAGEMENT_ROLES:

        raise HTTPException(
            status_code=400,
            detail="Invalid management role."
        )

    return normalized


# ============================================================
# DATABASE ROLE NORMALIZATION
# ============================================================

def normalize_database_role(
    role
) -> str:

    if role is None:
        return "EMPLOYEE"

    return (
        str(role)
        .strip()
        .upper()
        .replace("-", "_")
        .replace(" ", "_")
    )


# ============================================================
# PORTAL + ROLE AUTHORIZATION
# ============================================================
#
# IMPORTANT:
#
# Flutter role selection NEVER gives permission.
#
# Actual permission comes from:
#
# users.role
#
# Example:
#
# Database:
# role = Employee
#
# Flutter:
# Management -> Admin
#
# Result:
# 403
#
# Database:
# role = Admin
#
# Flutter:
# Management -> Admin
#
# Result:
# Allowed
#

def verify_portal_and_role(
    user: dict,
    portal: str,
    selected_role: str | None
):

    portal = normalize_portal(portal)

    selected_role = normalize_role(
        selected_role
    )

    database_role = normalize_database_role(
        user.get("role")
    )

    # ========================================================
    # EMPLOYEE PORTAL
    # ========================================================

    if portal == "employee":

        # Employee portal is for Employees.
        #
        # Admin is also allowed here because Admin
        # has full organization access.

        if database_role not in {
            "EMPLOYEE",
            "ADMIN"
        }:

            raise HTTPException(
                status_code=403,
                detail=(
                    "This account does not have "
                    "Employee Portal access."
                )
            )

        # Management role should not be supplied
        # when Employee portal is selected.

        if selected_role is not None:

            raise HTTPException(
                status_code=400,
                detail=(
                    "Management role is not allowed "
                    "in Employee Portal."
                )
            )

        return True

    # ========================================================
    # MANAGEMENT PORTAL
    # ========================================================

    if portal == "management":

        # Employee cannot enter Management Portal.

        if database_role not in VALID_MANAGEMENT_ROLES:

            raise HTTPException(
                status_code=403,
                detail=(
                    "This account does not have "
                    "Management Portal access."
                )
            )

        # Management role must be selected.

        if selected_role is None:

            raise HTTPException(
                status_code=400,
                detail=(
                    "Please select your management role."
                )
            )

        # Selected role must match actual database role.

        if selected_role != database_role:

            raise HTTPException(
                status_code=403,
                detail=(
                    "Selected management role does not "
                    "match your assigned role."
                )
            )

        return True

    return False


# ============================================================
# USER RESPONSE
# ============================================================

def build_user_response(
    user: dict,
    is_new_user: bool = False
):

    return {
        "id": user["id"],
        "name": user["name"],
        "email": user["email"],
        "role": user["role"],
        "status": user["status"],
        "is_new_user": is_new_user
    }


# ============================================================
# SIGNUP
# ============================================================

@app.post(
    "/api/auth/signup",
    status_code=status.HTTP_201_CREATED
)
def signup(
    user: SignupRequest
):

    # ========================================================
    # PHONE VALIDATION
    # ========================================================

    if not re.match(
        r"^\+?[0-9]{10,15}$",
        user.phone
    ):

        raise HTTPException(
            status_code=400,
            detail="Invalid phone number format."
        )

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor()

        # ====================================================
        # CHECK EXISTING EMAIL
        # ====================================================

        cursor.execute(
            """
            SELECT id
            FROM users
            WHERE LOWER(email) = LOWER(%s)
            """,
            (user.email,)
        )

        existing_user = cursor.fetchone()

        if existing_user:

            raise HTTPException(
                status_code=400,
                detail="Email already registered."
            )

        # ====================================================
        # BCRYPT PASSWORD HASH
        # ====================================================

        hashed_password = pwd_context.hash(
            user.password
        )

        # ====================================================
        # CREATE EMPLOYEE
        # ====================================================
        #
        # IMPORTANT:
        # Every normal signup becomes Employee.
        #
        # User cannot create Admin / Asset Manager /
        # Department Head from signup.
        #

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
                %s,
                'Employee',
                'Active'
            )
            RETURNING
                id,
                name,
                email,
                role,
                status,
                created_at
            """,
            (
                user.name,
                user.email,
                hashed_password
            )
        )

        new_user = cursor.fetchone()

        conn.commit()

        # ====================================================
        # RESPONSE
        # ====================================================

        return {
            "message": (
                "Employee account created successfully"
            ),

            "user": build_user_response(
                new_user,
                is_new_user=True
            )
        }

    except HTTPException:

        if conn:
            conn.rollback()

        raise

    except Exception as e:

        if conn:
            conn.rollback()

        print(
            "SIGNUP ERROR:",
            repr(e)
        )

        raise HTTPException(
            status_code=500,
            detail="Unable to create account."
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# EMAIL + PASSWORD LOGIN
# ============================================================

@app.post("/api/auth/login")
def login(
    credentials: LoginRequest
):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor()

        # ====================================================
        # NORMALIZE PORTAL
        # ====================================================

        portal = normalize_portal(
            credentials.portal
        )

        # ====================================================
        # NORMALIZE ROLE
        # ====================================================

        selected_role = normalize_role(
            credentials.role
        )

        # ====================================================
        # FIND USER
        # ====================================================

        cursor.execute(
            """
            SELECT
                id,
                name,
                email,
                password_hash,
                role,
                department_id,
                status,
                created_at
            FROM users
            WHERE LOWER(email) = LOWER(%s)
            """,
            (credentials.email,)
        )

        user = cursor.fetchone()

        if not user:

            raise HTTPException(
                status_code=401,
                detail="Invalid email or password."
            )

        # ====================================================
        # ACCOUNT STATUS
        # ====================================================

        if (
            str(user["status"])
            .strip()
            .upper()
            != "ACTIVE"
        ):

            raise HTTPException(
                status_code=403,
                detail="Your account is not active."
            )

        # ====================================================
        # GOOGLE-ONLY ACCOUNT
        # ====================================================

        if not user["password_hash"]:

            raise HTTPException(
                status_code=401,
                detail=(
                    "This account uses Google Sign-In. "
                    "Please continue with Google."
                )
            )

        # ====================================================
        # BCRYPT PASSWORD VERIFICATION
        # ====================================================

        try:

            password_valid = pwd_context.verify(
                credentials.password,
                user["password_hash"]
            )

        except Exception:

            password_valid = False

        if not password_valid:

            raise HTTPException(
                status_code=401,
                detail="Invalid email or password."
            )

        # ====================================================
        # PORTAL + ROLE AUTHORIZATION
        # ====================================================

        verify_portal_and_role(
            user,
            portal,
            selected_role
        )

        # ====================================================
        # RESPONSE
        # ====================================================

        return {
            "message": "Login successful",

            "portal": portal,

            "user": build_user_response(
                user,
                is_new_user=False
            )
        }

    except HTTPException:

        raise

    except Exception as e:

        print(
            "LOGIN ERROR:",
            repr(e)
        )

        raise HTTPException(
            status_code=500,
            detail="Login failed due to server error."
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# GOOGLE LOGIN
# ============================================================

@app.post("/api/auth/google-login")
def google_login(
    credentials: GoogleLoginRequest
):

    conn = None
    cursor = None

    try:

        conn = get_db_connection()
        cursor = conn.cursor()

        # ====================================================
        # NORMALIZE PORTAL
        # ====================================================

        portal = normalize_portal(
            credentials.portal
        )

        # ====================================================
        # NORMALIZE ROLE
        # ====================================================

        selected_role = normalize_role(
            credentials.role
        )

        # ====================================================
        # VERIFY GOOGLE ID TOKEN
        # ====================================================

        try:

            google_user = (
                id_token.verify_oauth2_token(
                    credentials.id_token,
                    google_requests.Request(),
                    GOOGLE_CLIENT_ID
                )
            )

        except ValueError:

            raise HTTPException(
                status_code=401,
                detail="Invalid Google ID token."
            )

        # ====================================================
        # GOOGLE INFORMATION
        # ====================================================

        google_id = google_user.get("sub")

        google_email = google_user.get(
            "email"
        )

        google_name = google_user.get(
            "name"
        )

        if (
            not google_id
            or not google_email
        ):

            raise HTTPException(
                status_code=401,
                detail=(
                    "Google account information "
                    "is incomplete."
                )
            )

        google_email = (
            google_email
            .strip()
            .lower()
        )

        google_name = (
            google_name
            or "Google User"
        )

        # ====================================================
        # CHECK OAUTH USERS
        # ====================================================

        cursor.execute(
            """
            SELECT *
            FROM oauth_users
            WHERE google_id = %s
            """,
            (google_id,)
        )

        oauth_user = cursor.fetchone()

        is_new_user = False

        user_id = None

        # ====================================================
        # EXISTING OAUTH USER
        # ====================================================

        if oauth_user:

            # ------------------------------------------------
            # OAuth account status
            # ------------------------------------------------

            if (
                str(oauth_user["status"])
                .strip()
                .upper()
                != "ACTIVE"
            ):

                raise HTTPException(
                    status_code=403,
                    detail=(
                        "Your Google account "
                        "access is inactive."
                    )
                )

            user_id = oauth_user["user_id"]

            # ------------------------------------------------
            # Safety check
            # ------------------------------------------------

            if user_id is None:

                # Try to reconnect by email.

                cursor.execute(
                    """
                    SELECT id
                    FROM users
                    WHERE LOWER(email) = LOWER(%s)
                    """,
                    (google_email,)
                )

                linked_user = cursor.fetchone()

                if linked_user:

                    user_id = linked_user["id"]

                    cursor.execute(
                        """
                        UPDATE oauth_users
                        SET
                            user_id = %s,
                            email = %s,
                            name = %s
                        WHERE google_id = %s
                        """,
                        (
                            user_id,
                            google_email,
                            google_name,
                            google_id
                        )
                    )

                else:

                    raise HTTPException(
                        status_code=404,
                        detail=(
                            "Google account is not linked "
                            "to an Orgaflow user."
                        )
                    )

        # ====================================================
        # NEW OAUTH USER
        # ====================================================

        else:

            # ------------------------------------------------
            # CHECK COMPANY USER BY EMAIL
            # ------------------------------------------------

            cursor.execute(
                """
                SELECT *
                FROM users
                WHERE LOWER(email) = LOWER(%s)
                """,
                (google_email,)
            )

            existing_user = cursor.fetchone()

            # ------------------------------------------------
            # EXISTING COMPANY USER
            # ------------------------------------------------

            if existing_user:

                user_id = existing_user["id"]

            # ------------------------------------------------
            # CREATE NEW EMPLOYEE
            # ------------------------------------------------

            else:

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
                        id
                    """,
                    (
                        google_name,
                        google_email
                    )
                )

                new_user = cursor.fetchone()

                user_id = new_user["id"]

                is_new_user = True

            # ------------------------------------------------
            # CREATE OAUTH MAPPING
            # ------------------------------------------------
            #
            # portal is stored for reference.
            #
            # role is NULL because actual authority
            # comes from users.role.
            #

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
                    'Active'
                )
                """,
                (
                    user_id,
                    google_id,
                    google_email,
                    google_name,
                    portal
                )
            )

        # ====================================================
        # GET ACTUAL USER
        # ====================================================

        cursor.execute(
            """
            SELECT
                id,
                name,
                email,
                password_hash,
                role,
                department_id,
                status,
                created_at
            FROM users
            WHERE id = %s
            """,
            (user_id,)
        )

        user = cursor.fetchone()

        if not user:

            raise HTTPException(
                status_code=404,
                detail="Application user not found."
            )

        # ====================================================
        # USER STATUS
        # ====================================================

        if (
            str(user["status"])
            .strip()
            .upper()
            != "ACTIVE"
        ):

            raise HTTPException(
                status_code=403,
                detail="Your account is not active."
            )

        # ====================================================
        # IMPORTANT:
        # ACTUAL ROLE COMES FROM users TABLE
        # ====================================================

        actual_role = normalize_database_role(
            user["role"]
        )

        print(
            "GOOGLE USER:",
            google_email
        )

        print(
            "GOOGLE PORTAL:",
            portal
        )

        print(
            "SELECTED ROLE:",
            selected_role
        )

        print(
            "DATABASE ROLE:",
            actual_role
        )

        # ====================================================
        # PORTAL + ROLE AUTHORIZATION
        # ====================================================

        verify_portal_and_role(
            user,
            portal,
            selected_role
        )

        # ====================================================
        # UPDATE OAUTH RECORD
        # ====================================================
        #
        # Keep latest name/email.
        #
        # Do NOT overwrite role with Flutter role.
        #

        cursor.execute(
            """
            UPDATE oauth_users
            SET
                user_id = %s,
                email = %s,
                name = %s,
                portal = %s
            WHERE google_id = %s
            """,
            (
                user["id"],
                google_email,
                google_name,
                portal,
                google_id
            )
        )

        conn.commit()

        # ====================================================
        # RESPONSE
        # ====================================================

        return {
            "message": "Google login successful",

            "portal": portal,

            "user": build_user_response(
                user,
                is_new_user=is_new_user
            )
        }

    except HTTPException:

        if conn:
            conn.rollback()

        raise

    except Exception as e:

        if conn:
            conn.rollback()

        print(
            "GOOGLE LOGIN ERROR:",
            repr(e)
        )

        raise HTTPException(
            status_code=500,
            detail="Google login failed due to server error."
        )

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()


# ============================================================
# ROOT
# ============================================================

@app.get("/")
def root():

    return {
        "message": "Orgaflow API is running"
    }