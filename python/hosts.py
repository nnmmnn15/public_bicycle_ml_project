import pymysql

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