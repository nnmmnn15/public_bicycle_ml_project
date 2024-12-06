import math
import requests
from API_KEY import URL
from hosts import connect
from auth import get_current_user
from fastapi import APIRouter ,HTTPException, Depends


router = APIRouter()

# 스테이션ID(Ex: 'ST-103') -> 남은 자전거수 : 15
# 요청실패 = -2
# 스테이션 정보없음 = -1
def getParkingBicycle(stationID):
    # print(stationID)
    # print(URL+f"{stationID}")
    response = requests.get(URL+f"{stationID}")
    # JSON 데이터 파싱
    if response.status_code == 200:  # 요청 성공 여부 확인
        try:
            data = response.json()  # JSON 데이터로 변환
            # print(data['rentBikeStatus']['row'][0]['stationName'])
            # print(data['rentBikeStatus']['row'][0]['parkingBikeTotCnt'])
            if data.get('MESSAGE') is not None:
                return (-1, '오류')
            else :
                return (int(data['rentBikeStatus']['row'][0]['parkingBikeTotCnt']), data['rentBikeStatus']['row'][0]['stationName'])
        except requests.exceptions.JSONDecodeError:
            return (-2, '오류')
    # return station_parking


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
async def station_loc(id:str=Depends(get_current_user)):
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
    # print(type(lat))
    # print(lat)
    # print(lng)
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

@router.get("/suspend_station_info")
async def suspend_station(id: str = Depends(get_current_user)):
    conn = connect()
    curs = conn.cursor()
    sql = "SELECT * FROM station"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    result = [
        {"id": row[0], "dong": row[1], "address": row[2], 'lat':row[3],'lng':row[4],'name':row[5]}
        for row in rows
    ]
    return {'results':result}

@router.get("/station_all")
async def stations(id: str = Depends(get_current_user)):
    conn = connect()
    curs = conn.cursor()
    sql = "SELECT * FROM station"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    result = [
        {"id": row[0], "dong" : row[1], "address":row[2], "lat": row[3], "lng": row[4], "name":row[5]}
        for row in rows
    ]
    return {'results':result}

@router.get("/station_parking_bike")
async def suspend_station():
    service_station_list = ['ST-1199',
    'ST-2330',
    'ST-2334',
    'ST-2341',
    'ST-2466',
    'ST-3002',
    'ST-3205',
    'ST-446',
    'ST-506']
    parkingBike = []
    conn = connect()
    try:
        with conn.cursor() as cursor:
            for station_id in service_station_list:
                # SQL 쿼리 작성
                sql = """
                SELECT id, lat, lng
                FROM station
                WHERE id = %s
                """
                
                # 쿼리 실행
                cursor.execute(sql, (station_id,))
                
                # 결과 가져오기
                results = cursor.fetchone()
                # print(results)
                parkingBike.append(list(results))
    finally:
        # 연결 종료
        conn.close()

    [station.append([i for i in getParkingBicycle(station[0])]) for station in parkingBike]
    # parkingBike = [getParkingBicycle(stationID) for stationID in service_station_list]
    # print(parkingBike)
    return {'results' : parkingBike}