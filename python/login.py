"""
author: 이원영
Description: login API with JWT
Fixed: 2024/10/7
Usage: 로그인시 JWT 토큰 인증절차를 통한 보안성 확보
"""
from datetime import datetime, timedelta
# from fastapi import APIRouter
from fastapi import Depends, FastAPI, HTTPException
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import Optional
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
import hosts

# router = APIRouter()
app = FastAPI()
SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
# JWT를 생성하고 검증할 때 사용되는 암고리즘
ALGORITHM = "HS256"
# JWT 토큰의 만료 시간 - 30분
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7

# Password 암호화
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# OAuth2 설정
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


# 사용자 데이터 모델
class User(BaseModel):
    id: str
    password : str
    age: int
    sex: str
    name: str

class UserInDB(User):
    password: str


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

async def get_user(id: str, password: str):
    user_data = await select(id=id) 
    results = user_data.get("results")
    if results:
        return results[0]  
    return None

async def authenticate_user(id: str, password: str):
    user = await get_user(id=id, password=pwd_context.hash(password))  # await 추가
    print(user)
    if not user or not verify_password(password, user["password"]):  # 딕셔너리 접근
        return False
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


async def select(id: str = None):
    conn = hosts.connect()
    curs = conn.cursor()
    sql = "SELECT * FROM user WHERE id=%s"
    curs.execute(sql, (id))
    rows = curs.fetchall()
    conn.close()
    result = [
        {"id": row[0], "password": row[1], "age": row[2], "sex": row[3], "name": row[4]}
        for row in rows
    ]
    return {"results": result}

# JWT 유효성 검증
def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("id")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return user_id
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


@app.get("/check")
async def check(id: str = None):
    conn = hosts.connect()
    curs = conn.cursor()
    sql = "SELECT count(*) FROM user WHERE id=%s"
    curs.execute(sql, (id))
    rows = curs.fetchall()
    conn.close()
    return {"results": list(rows[0])[0]}

# 토큰을 사용한 APi 예제 / Flutter에서 보낸 토큰의 유효성을 검사하여 토큰이 유효하면 sql결과값을 아니면 에러 발생
@app.get("/user/name")
async def get_user_name(id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    sql = "SELECT count(*) FROM user WHERE id=%s"
    curs.execute(sql, (id))
    rows = curs.fetchall()
    conn.close()
    if not rows:
        raise HTTPException(status_code=404, detail="User not found")
    return {"results": list(rows[0])[0]}



@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await authenticate_user(id=form_data.username, password=form_data.password)  # await 추가
    if not user:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password",
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    # access_token = create_access_token(data={"id": user["id"]})
    access_token = create_access_token(
        data={"id": user["id"], "password":user['password']}, expires_delta=access_token_expires
    )
    refresh_token = create_refresh_token( data={"id": user["id"], "password":user['password']})
    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

# refreshToken으로 새로운 accessToken 발급
@app.post("/token/refresh")
async def refresh_token(refresh_token: str):
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("id")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid refresh token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    
    # 새 accessToken 발급
    new_access_token = create_access_token(data={"id": user_id})
    return {"access_token": new_access_token, "token_type": "bearer"}


# 생성된 토큰을 통한 검증 테스트
@app.get("/users/me")
async def read_users_me(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        print(payload)
        username: str = payload.get("id")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    user = await get_user(payload.get("id"), payload.get('password'))
    print(user)
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    return user['id']

# db에 유저row를 생성할떄 password는 해싱된채로 넣기
@app.get("/signin")
def create_user(id: str, password: str, age: int, sex: str, name: str):
    try:
        hashed_password = pwd_context.hash(password)  # 비밀번호 해싱
        conn = hosts.connect()
        curs = conn.cursor()
        sql = "INSERT INTO user (id, password, age, sex, name) VALUES (%s, %s, %s, %s, %s)"
        curs.execute(sql, (id, hashed_password, age, sex, name))
        conn.commit()
        conn.close()
        return 1
    except:
        conn.close()
        return 0