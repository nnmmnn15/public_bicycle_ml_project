import pandas as pd
import joblib
import pymysql
from datetime import datetime
import os


witch = pd.read_csv('./ai_models/성동구의 대여소 위치(v3).csv', index_col=0)
dongs = pd.read_csv('./ai_models/격자좌표.csv', index_col=0)


def minmax_predict(station_num, date_time : datetime , humidity, rainfall, temperture, dong):
    ### 특정 스테이션과 특정 시간(유저에게서 받을 예정)
    station_num = 3559
    time = date_time.hour

    ### 날씨 API를 통해서 가져올 데이터cd
    humidity = 2
    rainfall = 0
    temperture = -11.3


    month = date_time.month
    weekday = date_time.weekday()


    ### 비가 왔는지 안왔는지 판별
    def categorize_Israin(rain):
        if rain == 0:
            return 0
        else :
            return 1
    israin = categorize_Israin(rainfall)


    #### 달을 받아 DB에서 찾아올 계절, 계절이름을 반환하는 함수
    def get_season(month):
        if month in [3, 4, 5]:
            return 1, 'spring'
        elif month in [6, 7, 8]:
            return 2, 'summer'
        elif month in [9, 10, 11]:
            return 3, 'fall'
        elif month in [12, 1, 2]:
            return 4, 'winter'
        

    ### 요일을받아 주중 주말을 결정해주는 함수
    def get_holiday(day):
        if day < 5:
            return 'weekday'
        else:
            return 'holiday'


    season, season_name = get_season(month)
    week_holi = get_holiday(weekday)



    ### db연동 ------------------------------------------------------------------------------------------------------------------------------------
    bicycle = 'svc.sel4.cloudtype.app'

    def connect():
        conn = pymysql.connect(
            host=bicycle,
            user='bicycle',
            password='wy12wy10',
            charset='utf8',
            db='bicycle',
            port=32176
        )
        return conn


    conn = connect()
    curs = conn.cursor()

    #### 비슷한 곳 하나만 가져옴
    sql = """
        SELECT * 
        FROM population 
        WHERE id = %s
            AND season = %s
            AND day = %s
            AND time = %s
    """
    curs.execute(sql, [dong, season, weekday, time])
    rows = curs.fetchall()

    conn.close()
    result = rows
    pop_df =  pd.DataFrame(rows)
    pop_df.columns = ['행정동','계절','요일','시간','총','10대','20대','30대','40대','50대','60대']


    #### DB연동 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

    #### 데이터 만들기 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    temperture_df_columns =  ['습도(%)', '강수량(mm)', '기온(°C)', '강수여부']
    temperture_df =  pd.DataFrame(
        {
            temperture_df_columns[0] : [humidity],
            temperture_df_columns[1] : [rainfall],
            temperture_df_columns[2] : [temperture],
            temperture_df_columns[3] : [israin],
        }
    )

    concated_data = pd.concat([pop_df.reset_index(drop=True), temperture_df], axis=1)
    test_data = pd.concat([concated_data.iloc[:, [3]], concated_data.iloc[:, 4:]], axis=1)
    test_data['시간'] =  test_data['시간'].astype(int)
    test_data.drop('50대', axis= 1, inplace = True)

    #### 데이터 만들기 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

    #### 모델 불러오기 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    rent_model = joblib.load(f'ai_models/{season_name}_{week_holi}_rent/best_model_{station_num}.joblib')
    turn_model = joblib.load(f'ai_models/{season_name}_{week_holi}_turn/best_model_{station_num}.joblib')
    #### 모델 불러오기 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    #### 예측하고 결과 보내기 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    rent_columns= ['대여시', '총생활인구수', '10대_생활인구수', '20대_생활인구수', '30대_생활인구수', '40대_생활인구수', '60대_생활인구수', '습도(%)', '강수량(mm)', '기온(°C)', '강수여부']
    test_data.columns = rent_columns
    rent_predicted =  rent_model.predict(test_data).item()

    turn_columns= ['반납시', '총생활인구수', '10대_생활인구수', '20대_생활인구수', '30대_생활인구수', '40대_생활인구수', '60대_생활인구수', '습도(%)', '강수량(mm)', '기온(°C)', '강수여부']
    test_data.columns = turn_columns
    turn_predicted =  turn_model.predict(test_data).item()


    rmses_df =  pd.read_csv(f'ai_models/metadata_{season_name}_{week_holi}.csv', index_col=0)
    rent_rmse =  rmses_df.loc[station_num, '대여']
    turn_rmse =  rmses_df.loc[station_num, '반납']
    max_bike =  turn_predicted + turn_rmse - rent_predicted + rent_rmse
    min_bike =  turn_predicted - turn_rmse - rent_predicted - rent_rmse
    #### 예측하고 결과 보내기 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

    ### 결과
    return min_bike, max_bike