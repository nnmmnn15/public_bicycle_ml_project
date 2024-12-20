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
import user_state

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
    sql = "SELECT name FROM user WHERE id=%s"
    curs.execute(sql, (id))
    rows = curs.fetchall()
    conn.close()
    if not rows:
        raise HTTPException(status_code=404, detail="User not found")
    return {"results": list(rows[0])[0]}

# 유저의 대여, 예약 상태
@router.get("/action_state")
async def getActionState(id: str = Depends(get_current_user)):
    # 예약 상태
    reservation_state = user_state.reservationState(id)
    rent_state = user_state.rentState(id)
    if not reservation_state and not rent_state:
        return {'results' : [{'state':0}]}
    elif reservation_state and not rent_state:
        # 예약 상태
        value = user_state.reservationInfo(id)
        return {'results' : [{'state':1},{'value' : value}]}
    elif not reservation_state and rent_state:
        # 빌린 상태
        value = user_state.rentInfo(id)
        print(value)
        return {'results' : [{'state':2}, {'value' : value}]}
    else:
        return {'results' : [{'state':0}]}
    

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


#########################################################################################################

# ********************************* 여기 처리 바람 ************************************#

############################################################################################################


@router.get("/user/{user_id}")
async def get_user_info(user_id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    try:
        # 사용자 정보만 먼저 조회
        sql = "SELECT * FROM user WHERE id=%s"
        curs.execute(sql, (user_id,))
        user_info = curs.fetchone()
        
        return {
            "user_info": {
                "id": user_info[0],
                "age": user_info[2],
                "sex": user_info[3],
                "name": user_info[4]
            }
        }
    finally:
        conn.close()

@router.get("/user/{user_id}/reservations")
async def get_user_reservations(user_id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    try:
        sql = """
            SELECT r.*, s.name as station_name 
            FROM reservation r 
            JOIN station s ON r.station_id = s.id 
            WHERE r.user_id = %s
        """
        curs.execute(sql, (user_id,))
        rows = curs.fetchall()
        return {"reservations": rows}
    finally:
        conn.close()

@router.get("/user/{user_id}/rent-history")
async def get_user_rent_history(user_id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    try:
        sql = "SELECT * FROM rent WHERE user_id = %s ORDER BY start_time DESC"
        curs.execute(sql, (user_id,))
        rows = curs.fetchall()
        return {"rent_history": rows}
    finally:
        conn.close()

@router.get("/user/{user_id}/coupons")
async def get_user_coupons(user_id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    try:
        sql = """
            SELECT c.* FROM coupon c 
            WHERE c.user_id = %s AND c.is_used = 0 
            AND c.expiry_date > CURRENT_TIMESTAMP
        """
        curs.execute(sql, (user_id,))
        rows = curs.fetchall()
        return {"coupons": rows}
    finally:
        conn.close()

@router.get("/user/{user_id}/stats")
async def get_user_stats(user_id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    try:
        # 총 이용 횟수와 시간
        sql = """
            SELECT COUNT(*) as total_rides, 
                   SUM(time) as total_time 
            FROM rent 
            WHERE user_id = %s
        """
        curs.execute(sql, (user_id,))
        stats = curs.fetchone()
        return {"stats": stats}
    finally:
        conn.close()    


@router.delete("/reservation/{reservation_id}")
async def delete_reservation(user_id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    try:
        sql = "DELETE FROM reservation WHERE id = %s"
        curs.execute(sql, (user_id,))
        conn.commit()
        return {"message": "Reservation cancelled successfully"}
    finally:
        conn.close()        
        

@router.post("/coupons/receive/{coupon_id}")
async def receive_coupon(coupon_id: str, user_id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    try:
        # 쿠폰 발급
        sql = "UPDATE coupon SET user_id = %s WHERE coupon_id = %s"
        curs.execute(sql, (user_id, coupon_id))
        
        # 쿠폰 사용 내역 추가
        sql = "INSERT INTO coupon_usage (user_id, coupon_id, received_date) VALUES (%s, %s, CURRENT_TIMESTAMP)"
        curs.execute(sql, (user_id, coupon_id))
        
        conn.commit()
        return {"message": "Coupon received successfully"}
    finally:
        conn.close()        
        


@router.get("/coupons/available")
async def get_available_coupons(user_id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    try:
        sql = """
            SELECT c.*, s.store_name, s.category 
            FROM coupon c
            JOIN store s ON c.store_id = s.store_id
            WHERE c.is_used = 0 
            AND c.expiry_date > CURRENT_TIMESTAMP
            AND c.user_id IS NULL
        """
        curs.execute(sql)
        rows = curs.fetchall()
        result = []
        for row in rows:
            result.append({
                "coupon_id": row[0],
                "store_id": row[1],
                "store_name": row[2],
                "discount_amount": row[3],
                "issue_date": row[4],
                "expiry_date": row[5],
                "is_used": row[6],
                "location": row[7],
                "category": row[8]
            })
        return {"coupons": result}
    finally:
        conn.close()

@router.get("/user/{user_id}/coupons")
async def get_user_coupons(user_id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    try:
        sql = """
            SELECT c.*, s.store_name, s.category 
            FROM coupon c
            JOIN store s ON c.store_id = s.store_id
            WHERE c.user_id = %s 
            AND c.is_used = 0 
            AND c.expiry_date > CURRENT_TIMESTAMP
        """
        curs.execute(sql, (user_id,))
        rows = curs.fetchall()
        result = []
        for row in rows:
            result.append({
                "coupon_id": row[0],
                "store_id": row[1],
                "store_name": row[2],
                "discount_amount": row[3],
                "issue_date": row[4],
                "expiry_date": row[5],
                "is_used": row[6],
                "used_time": row[7],
                "issue_number": row[8],
                "user_id": row[9],
                "location": row[10],
                "category": row[11]
            })
        return {"coupons": result}
    finally:
        conn.close()