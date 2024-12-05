"""
author: 이원영
Description: login API with JWT
Fixed: 2024/10/7
Usage: 로그인시 JWT 토큰 인증절차를 통한 보안성 확보
"""
from fastapi import APIRouter
from fastapi import Depends, HTTPException
from passlib.context import CryptContext
import hosts
from auth import get_current_user

router = APIRouter()
# Password 암호화(해싱)
ALGORITHM = "HS256"
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

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


# db에 유저row를 생성할떄 password는 해싱된채로 넣기
@router.get("/signin")
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

# 토큰을 사용한 APi 예제 / Flutter에서 보낸 토큰의 유효성을 검사하여 토큰이 유효하면 sql결과값을 아니면 에러 발생
@router.get("/user/name")
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

# 회원가입시 사용되어 db에 user정보를 insert
# async def get_user_name(id: str = Depends(get_current_user)):
#     conn = hosts.connect()
#     curs = conn.cursor()
#     sql = "SELECT count(*) FROM user WHERE id=%s"
#     curs.execute(sql, (id))
#     rows = curs.fetchall()
#     conn.close()
#     if not rows:
#         raise HTTPException(status_code=404, detail="User not found")
#     return {"results": list(rows[0])[0]}