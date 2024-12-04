from fastapi import APIRouter ,HTTPException, Depends
from auth import get_current_user
import hosts
# FastAPI객체 생성
router = APIRouter()

# 
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