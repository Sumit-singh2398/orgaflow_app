from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from passlib.context import CryptContext
import psycopg2
from psycopg2.extras import RealDictCursor
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
import re


app = FastAPI()

# GOOGLE CONFIGURATION

GOOGLE_CLIENT_ID = (
    "449981088129-fptar4p18jkmsgk6avhigqintmv0qha3.apps.googleusercontent.com"
)
# PASSWORD HASHING


pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)



# DATABASE

def get_db_connection():
    return psycopg2.connect(
        host="localhost",
        database="orgaflow_db",
        user="postgres",
        password="",
        cursor_factory=RealDictCursor
    )



# REQUEST MODELS


class SignupRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    phone: str = Field(..., min_length=10, max_length=15)
    password: str = Field(..., min_length=6)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    portal: str
    role: str | None = None


class GoogleLoginRequest(BaseModel):
    id_token: str
    portal: str
    role: str | None = None



# HELPERS

VALID_PORTALS = {
    "employee", 
    "management"
}

VALID_MANAGEMENT_ROLES = {
    "ADMIN",
    "ASSET_MANAGER",
    "DEPARTMENT_HEAD"
}


def normalize_portal(portal: str) -> str:
    portal = portal.strip().lower()

    if portal not in VALID_PORTALS:
        raise HTTPException(
            status_code=400,
            detail="Invalid portal selected."
        )

    return portal


def normalize_role(role: str | None) -> str | None:
    if role is None:
        return None

    role = role.strip().upper()

    if role not in VALID_MANAGEMENT_ROLES:
        raise HTTPException(
            status_code=400,
            detail="Invalid management role."
        )

    return role


def verify_portal_and_role(
    user: dict,
    portal: str,
    selected_role: str | None
):
    portal = normalize_portal(portal)
    selected_role = normalize_role(selected_role)

    database_role = str(user["role"]).upper()

# EMPLOYEE PORTAL
  

    if portal == "employee":

        if database_role != "EMPLOYEE":
            raise HTTPException(
                status_code=403,
                detail="This account does not have Employee Portal access."
            )

        if selected_role is not None:
            raise HTTPException(
                status_code=400,
                detail="Management role is not allowed in Employee Portal."
            )

        return True

    # MANAGEMENT PORTAL
    

    if portal == "management":

        if database_role not in VALID_MANAGEMENT_ROLES:
            raise HTTPException(
                status_code=403,
                detail="This account does not have Management Portal access."
            )

        if selected_role != database_role:
            raise HTTPException(
                status_code=403,
                detail="Selected management role does not match your assigned role."
            )

        return True

    return False

# NORMAL SIGNUP


@app.post(
    "/api/auth/signup",
    status_code=status.HTTP_201_CREATED
)
def signup(user: SignupRequest):

    if not re.match(r"^\+?[0-9]{10,15}$", user.phone):
        raise HTTPException(
            status_code=400,
            detail="Invalid phone number format"
        )

    conn = get_db_connection()
    cursor = conn.cursor()

    try:

        cursor.execute(
            "SELECT * FROM users WHERE email = %s",
            (user.email,)
        )

        existing_user = cursor.fetchone()

        if existing_user:
            raise HTTPException(
                status_code=400,
                detail="Email already registered"
            )

        hashed_password = pwd_context.hash(user.password)

        cursor.execute(
            """
            INSERT INTO users
            (
                name,
                email,
                password_hash,
                role
            )
            VALUES
            (
                %s,
                %s,
                %s,
                'Employee'
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

        return {
            "message": "Employee account created successfully",
            "user": new_user
        }

    except HTTPException:
        conn.rollback()
        raise

    except Exception as e:
        conn.rollback()

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

    finally:
        cursor.close()
        conn.close()

# EMAIL + PASSWORD LOGIN


@app.post("/api/auth/login")
def login(credentials: LoginRequest):

    conn = get_db_connection()
    cursor = conn.cursor()

    try:

        portal = normalize_portal(credentials.portal)

        selected_role = normalize_role(credentials.role)

        cursor.execute(
            """
            SELECT *
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

        if user["status"].upper() != "ACTIVE":
            raise HTTPException(
                status_code=403,
                detail="Your account is not active."
            )

        if not user["password_hash"]:
            raise HTTPException(
                status_code=401,
                detail="This account uses Google Sign-In."
            )

        if not pwd_context.verify(
            credentials.password,
            user["password_hash"]
        ):
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password."
            )

        verify_portal_and_role(
            user,
            portal,
            selected_role
        )

        return {
            "message": "Login successful",
            "portal": portal,
            "user": {
                "id": user["id"],
                "name": user["name"],
                "email": user["email"],
                "role": user["role"],
                "status": user["status"]
            }
        }

    except HTTPException:
        raise

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

    finally:
        cursor.close()
        conn.close()
# GOOGLE OAUTH LOGIN

@app.post("/api/auth/google-login")
def google_login(credentials: GoogleLoginRequest):

    conn = get_db_connection()
    cursor = conn.cursor()

    try:

        portal = normalize_portal(credentials.portal)

        selected_role = normalize_role(credentials.role)

         # VERIFY GOOGLE ID TOKEN


        try:

            google_user = id_token.verify_oauth2_token(
                credentials.id_token,
                google_requests.Request(),
                GOOGLE_CLIENT_ID
            )

        except ValueError:

            raise HTTPException(
                status_code=401,
                detail="Invalid Google ID token."
            )

        google_id = google_user.get("sub")
        google_email = google_user.get("email")
        google_name = google_user.get("name")

        if not google_id or not google_email:
            raise HTTPException(
                status_code=401,
                detail="Google account information is incomplete."
            )
 # GOOGLE ACCOUNT
        

        cursor.execute(
            """
            SELECT *
            FROM oauth_users
            WHERE google_id = %s
            """,
            (google_id,)
        )

        oauth_user = cursor.fetchone()

        # EXISTING GOOGLE ACCOUNT
        

        if oauth_user:

            if oauth_user["status"].upper() != "ACTIVE":
                raise HTTPException(
                    status_code=403,
                    detail="Your Google account access is inactive."
                )

            user_id = oauth_user["user_id"]

          # NEW GOOGLE ACCOUNT

        else:

            # Check whether the Google email already
            # belongs to an existing company user.

            cursor.execute(
                """
                SELECT *
                FROM users
                WHERE LOWER(email) = LOWER(%s)
                """,
                (google_email,)
            )

            existing_user = cursor.fetchone()

            if existing_user:

                user_id = existing_user["id"]

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
                    RETURNING id
                    """,
                    (
                        google_name or "Google User",
                        google_email
                    )
                )

                new_user = cursor.fetchone()

                user_id = new_user["id"]

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
                RETURNING *
                """,
                (
                    user_id,
                    google_id,
                    google_email,
                    google_name or "Google User",
                    portal
                )
            )
        # GET ACTUAL APPLICATION USER


        cursor.execute(
            """
            SELECT *
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

        if user["status"].upper() != "ACTIVE":

            raise HTTPException(
                status_code=403,
                detail="Your account is not active."
            )
 # VERIFY PORTAL + ACTUAL ROLE
        verify_portal_and_role(
            user,
            portal,
            selected_role
        )

        conn.commit()

        return {
            "message": "Google login successful",
            "portal": portal,
            "user": {
                "id": user["id"],
                "name": user["name"],
                "email": user["email"],
                "role": user["role"],
                "status": user["status"]
            }
        }

    except HTTPException:

        conn.rollback()
        raise

    except Exception as e:

        conn.rollback()

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

    finally:

        cursor.close()
        conn.close()

@app.get("/")
def root():
    return {
        "message": "Orgaflow API is running"
    }