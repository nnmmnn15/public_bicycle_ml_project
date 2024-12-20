from fastapi import APIRouter ,HTTPException, Depends
from auth import get_current_user
import hosts
import station
from datetime import datetime, timedelta
import pytz
# FastAPI객체 생성
router = APIRouter()
korea_now = datetime.now(pytz.timezone('Asia/Seoul'))

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


@router.get("/ava_station")
async def available_station(id: str = Depends(get_current_user),lat: float = None, lng: float= None):
    all_station = await station.stations(id)
    distances = [int(station.haversine(lat,lng,sta['lat'],sta['lng'])) for sta in all_station['results']]
    under_25 = []
    for distance, sta in zip(distances, all_station['results']):
        if distance < 25:
            under_25.append(sta['id'])
    return {"results": under_25}

# 사용자의 연장 신청을 받아 처리하기
@router.get("/prolongation")
async def process_prolong(id: str = Depends(get_current_user), resume : int =None, wantresume : int=None, lat: float = None, lng: float= None):
    if wantresume > resume:
        raise HTTPException(status_code=404, detail='1시간 대여자는 1시간 연장할 수 없습니다.')
    current_rent = await get_current_rent(id)
    print(current_rent)
    if current_rent['results']['resume'] == 0:
        return {"results" : 0}
    all_station = await station.stations(id)
    print(all_station['results'][0])
    distances = [station.haversine(lat,lng,sta['lat'],sta['lng']) for sta in all_station['results']]
    print(distances)
    start_time_str = current_rent['results']['start_time']
    start_time = datetime.strptime(start_time_str, "%Y-%m-%d %H:%M")
    for distance in distances:
        if distance < 25:
            new_end_time = start_time + timedelta(minutes=30 * wantresume)
            
            # 데이터베이스 업데이트
            conn = hosts.connect()
            curs = conn.cursor()
            sql = "update rent set resume = %s, start_time = %s where id = %s"
            curs.execute(sql, (0, new_end_time.strftime("%Y-%m-%d %H:%M"), current_rent['results']['id']))
            conn.commit()
            conn.close()
            
            return {"results": 1}
    return {"results" : "Over the 25 Radius"}
