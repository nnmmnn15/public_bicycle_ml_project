from fastapi import APIRouter ,HTTPException, Depends
from auth import get_current_user
import hosts
# FastAPI객체 생성
router = APIRouter()

# 현재 사용자의 마지막 대여 정보 가져오기
@router.get("/current")
async def get_current_rent(id: str = Depends(get_current_user)):
    conn = hosts.connect()
    curs = conn.cursor()
    sql = "SELECT * FROM rent WHERE user_id=%s order by start_time desc LIMIT 1"
    curs.execute(sql, (id))
    rows = curs.fetchall()
    conn.close()
    if not rows:
        raise HTTPException(status_code=404, detail="User not found")
    results = [
        {"id": row[0], "bic_id": row[1], "user_id": row[2], "start_time": row[3], "time": row[4], "resume":row[5]}
        for row in rows
    ]
    print(results[0])
    return {"results": results[0]}

# 사용자의 연장 신청을 받아 처리하기
@router.get("/prolongation")
async def process_prolong(id: str = Depends(get_current_user), resume : int =None, wantresume : int=None):
    if resume == 0:
        raise HTTPException(status_code=404, detail="No More Token")
    if wantresume > resume:
        raise HTTPException(status_code=404, detail='1시간 대여자는 1시간 연장할 수 없습니다.')
    current_rent = await get_current_rent(id)
    print(current_rent)
    conn = hosts.connect()
    curs = conn.cursor()
    sql = "update rent set resume = %s, time = %s where id = %s"
    curs.execute(sql, (0, int(current_rent['results']['time']) + 30*wantresume , current_rent['results']['id']))
    conn.commit()
    conn.close()
    return {"results": 'Update Success'}