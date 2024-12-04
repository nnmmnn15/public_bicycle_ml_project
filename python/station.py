import math
import requests
from API_KEY import URL
from hosts import connect

from fastapi import APIRouter

router = APIRouter()

# 스테이션ID(Ex: 'ST-103') -> 남은 자전거수 : 15
# 요청실패 = -2
# 스테이션 정보없음 = -1
def getParkingBicycle(stationID):
    response = requests.get(URL+f"/{stationID}")
    # JSON 데이터 파싱
    if response.status_code == 200:  # 요청 성공 여부 확인
        try:
            data = response.json()  # JSON 데이터로 변환
            if data.get('MESSAGE') is not None:
                station_parking = {stationID : -1}
            else :
                station_parking = {stationID : int(data['rentBikeStatus']['row'][0]['parkingBikeTotCnt'])}
        except requests.exceptions.JSONDecodeError:
            station_parking = {stationID : -2}
    return station_parking


def haversine(lat1, lon1, lat2, lon2):
    # 지구 반지름 (미터)
    R = 6371000

    # 위도와 경도를 라디안으로 변환
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    # Haversine 공식 적용
    a = math.sin(delta_phi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # 두 지점 간의 거리 계산
    distance = R * c

    return distance

# # 예시: 두 지점의 위도와 경도
# lat1, lon1 = 37.4948246, 127.0301152  # 서울
# lat2, lon2 = 37.494857, 127.029843  # 부산



@router.get("/station_all_loc")
async def station_loc():
    conn = connect()
    curs = conn.cursor()
    sql = "SELECT id, name, lat, lng FROM station"
    curs.execute(sql, (id))
    rows = curs.fetchall()
    conn.close()
    result = [
        {"id": row[0], "name": row[1], "lat": row[2], "lng": row[3]}
        for row in rows
    ]
    return {'results':result}


@router.get("/suspend_station")
async def suspend_station(lat: float = None, lng: float= None):
    # lat = float(lat)
    # lng = float(lng)
    print(type(lat))
    print(lat)
    print(lng)
    conn = connect()
    curs = conn.cursor()
    sql = "SELECT name, lat, lng FROM station"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    result = [
        {"name": row[0], "lat": row[1], "lng": row[2]}
        for row in rows
    ]
    for loc in result:
        loc['distance'] = haversine(lat,lng, loc['lat'], loc['lng'])
    return {'results':result}

