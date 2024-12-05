from datetime import datetime, timedelta
import hosts

def rentState(user_id):
    conn = hosts.connect()
    curs = conn.cursor()
    sql = """
        SELECT *
        FROM rent
        WHERE user_id = %s
        ORDER BY id DESC
        LIMIT 1
        """
        
    # 쿼리 실행
    curs.execute(sql, (user_id,))
    
    # 결과 가져오기
    result = curs.fetchone()
    curs.close()
    conn.close()
    startTime = datetime.strptime(result[3], '%Y-%m-%d %H:%M')
    endTime = startTime + timedelta(minutes=int(result[4]))
    now = datetime.now()
    # 빌린 상태 = True
    # 안빌린 상태 = False
    result_value = endTime > now
    return result_value

def reservationState(user_id):
    conn = hosts.connect()
    curs = conn.cursor()
    sql = """
        SELECT *
        FROM reservation
        WHERE user_id = %s
        ORDER BY id DESC
        LIMIT 1
        """
        
    # 쿼리 실행
    curs.execute(sql, (user_id,))
    
    # 결과 가져오기
    result = curs.fetchone()
    curs.close()
    conn.close()
    rev_time = datetime.strptime(result[5], '%Y-%m-%dT%H:%M:%S')
    now = datetime.now()
    # print(rev_time, now)
    # 예약 상태 = True
    # 예약없는 상태 = False
    result_value = rev_time > now
    # print(result_value)
    return result_value

def rentInfo(user_id):
    conn = hosts.connect()
    curs = conn.cursor()
    sql = """
        SELECT *
        FROM rent
        WHERE user_id = %s
        ORDER BY id DESC
        LIMIT 1
        """
        
    # 쿼리 실행
    curs.execute(sql, (user_id,))
    
    # 결과 가져오기
    result = curs.fetchone()
    curs.close()
    conn.close()
    startTime = datetime.strptime(result[3], '%Y-%m-%d %H:%M')
    endTime = startTime + timedelta(minutes=int(result[4]))
    now = datetime.now()
    rest_time = endTime - now
    # 분
    # print(rest_time.seconds//60)
    # 초
    # print(rest_time.seconds%60)
    return rest_time.seconds//60

def reservationInfo(user_id):
    conn = hosts.connect()
    curs = conn.cursor()
    sql = """
        SELECT rev_time, time, name, r.id as id
        FROM reservation r
        INNER JOIN station s ON r.station_id = s.id
        WHERE r.user_id = %s
        ORDER BY r.id DESC
        LIMIT 1;
        """
        
    # 쿼리 실행
    curs.execute(sql, (user_id,))
    
    # 결과 가져오기
    result = curs.fetchone()
    curs.close()
    conn.close()
    result = list(result)
    result[0]=result[0].split('T')[1]
    return(result)

reservationInfo("wylee99")