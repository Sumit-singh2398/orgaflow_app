from fastapi import FastAPI, HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, EmailStr, Field
from passlib.context import CryptContext
import psycopg2
from psycopg2.extras import RealDictCursor
import jwt
from datetime import datetime, timedelta
import re

app = FastAPI()

# JWT Configuration
SECRET_KEY = "your_super_secret_key_here_change_in_production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 

# Password hashing configuration
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/auth/login")


def get_db_connection():
    conn = psycopg2.connect(
        host="localhost",
        database="orgaflow_db",  # Updated to match your database name
        user="postgres",
        password="mehra",  
        cursor_factory=RealDictCursor
    )
    return conn

# Pydantic Models with Validation
class SignupRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    phone: str = Field(..., min_length=10, max_length=15)
    password: str = Field(..., min_length=6)

class LoginRequest(BaseModel):
    email: EmailStr
    password: str


def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

@app.post("/api/auth/signup", status_code=status.HTTP_201_CREATED)
def signup(user: SignupRequest):
    # Additional server-side validation for phone number pattern
    if not re.match(r'^\+?[0-9]{10,15}$', user.phone):
        raise HTTPException(status_code=400, detail="Invalid phone number format")

    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute("SELECT * FROM users WHERE email = %s", (user.email,))
        existing_user = cursor.fetchone()
        if existing_user:
            raise HTTPException(status_code=400, detail="Email already registered")
        
        hashed_password = pwd_context.hash(user.password)
        
        # Note: Ensure your users table has a 'phone' column if you want to store it
        cursor.execute(
            """
            INSERT INTO users (name, email, password_hash, role) 
            VALUES (%s, %s, %s, 'Employee') 
            RETURNING id, name, email, role, status, created_at
            """,
            (user.name, user.email, hashed_password)
        )
        new_user = cursor.fetchone()
        conn.commit()
        
        return {
            "message": "Employee account created successfully",
            "user": new_user
        }
        
    except HTTPException as he:
        conn.rollback()
        raise he
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()

@app.post("/api/auth/login")
def login(credentials: LoginRequest):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute("SELECT * FROM users WHERE email = %s", (credentials.email,))
        user = cursor.fetchone()
        
        if not user:
            raise HTTPException(status_code=401, detail="Invalid email or password")
        
        if not pwd_context.verify(credentials.password, user['password_hash']):
            raise HTTPException(status_code=401, detail="Invalid email or password")
        
        access_token = create_access_token(data={"sub": user['email'], "role": user['role']})
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": user['id'],
                "name": user['name'],
                "email": user['email'],
                "role": user['role']
            }
        }
        
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()