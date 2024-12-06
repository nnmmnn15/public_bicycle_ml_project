import math
import requests
from API_KEY import URL, API_ATMOS
from hosts import connect
from auth import get_current_user
from fastapi import APIRouter ,HTTPException, Depends
from datetime import datetime, timedelta
import ml
import pandas as pd




router = APIRouter()




def atmosphere(dong, predict_datetime):
    
    API_atmos = API_ATMOS
    base_url = 'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst'
    
    # dong = '왕십리2동'

    # predict_datetime = datetime(2024, 12, 5, 22)

    now =  datetime.now()
    if int(now.strftime('%M')) < 30:
        now = now - timedelta(hours=1)
    else:
        now = now - timedelta(minutes=1)

    base_date =  now.strftime('%Y%m%d')
    base_time = now.strftime('%H%M')
    nx = list(ml.dongs.loc[dong])[0]
    ny = list(ml.dongs.loc[dong])[1]

    predict_date = predict_datetime.strftime('%Y%m%d')
    predict_time = predict_datetime.strftime('%H')

    send_url =  [f'serviceKey={API_atmos}','pageNo=1','numOfRows=1000','dataType=JSON',f'base_date={base_date}',f'base_time={base_time}',f'nx={nx}',f'ny={ny}',]
    http =  'http' + base_url[5:]
    json_url =  http +'?'+ '&'.join(send_url)

    response = requests.get(json_url)
    if response.status_code == 200:
        data = response.json()
        # 이제 data 변수에 파싱된 JSON 데이터가 저장됩니다
        # 예: print(data["key"])
    else:
        print("Request failed with status code:", response.status_code)

    yaho =  data['response']['body']['items']['item']
    atmos_dict =  {temp_dict['category']:temp_dict['fcstValue'] for temp_dict in yaho if (temp_dict['category'] in ['RN1','REH','T1H']) & (temp_dict['fcstDate'] == predict_date) & (temp_dict['fcstDate'] == predict_date) & (temp_dict['fcstTime'][:2] == predict_time) }

    return atmos_dict






@router.get("/ai")
async def ai_predict(stid : str = None, predictTime : str = None, curBikes :str = None ):

    # stid = 'ST-1199'
    # predictTime = '20241205T22'
    # curBikes = '20'



    dong =  ml.witch.set_index('대여소ID')['행정동'][stid]
    input_predictTime =  datetime.strptime(predictTime, '%Y%m%dT%H')
    atmosphere_dict =  atmosphere(dong, input_predictTime)

    try:
        rainfall = int(atmosphere_dict['RN1'])
    except:
        rainfall =  0
    humidity = float(atmosphere_dict['REH'])
    temperture = float(atmosphere_dict['T1H'])
    stnum = ml.witch.set_index('대여소ID')['대여소번호'][stid]


    pred_min_bike, pred_max_bike =  ml.minmax_predict(stnum, input_predictTime, humidity, rainfall, temperture, dong)
    min_bike = int(curBikes) + pred_min_bike
    max_bike = int(curBikes) + pred_max_bike

    return {'min_bike' : min_bike, 'max_bike' : max_bike}














@router.get("/bikeInSt")
async def bikeInSt(statn :str = None ):
    conn = connect()
    curs = conn.cursor()
    ### 여긴 지우자
    # statn = 'ST-1199',
    user = 'wylee99'
    #####
    sql = """
        SELECT id
        FROM bicycle
        WHERE station = %s
    """
    curs.execute(sql, (statn))
    bike = curs.fetchone()[0]
    conn.close()
    current_time = datetime.now().strftime("%Y-%m-%dT%H:%M:00")

    # print(current_time)

    conn = connect()
    curs = conn.cursor()
    sql = """
        INSERT INTO reservation (station_id, bic_id, user_id, time, rev_time)
        VALUES (%s, %s, %s, %s, %s)
    """
    curs.execute(sql, (statn, bike, user, 120, current_time))

    rows = curs.fetchone()
    conn.commit()
    conn.close()
    print(rows)


    return {'results': bike}

