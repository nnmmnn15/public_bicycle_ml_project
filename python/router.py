from fastapi import FastAPI
import pymysql, hosts
from fastapi.middleware.cors import CORSMiddleware
from auth import router as auth_router
from rent import router as rent_router
from station import router as station_router
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용 (필요에 따라 제한 가능)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def connect():
    conn = pymysql.connect(
        host=hosts.bicycle,
        user='root',
        password='qwer1234',
        charset='utf8',
        db='bicycle',
        port=32176
    )
    return conn


app.include_router(auth_router, prefix="/auth", tags=["auth"])
app.include_router(rent_router, prefix="/rent", tags=["rent"])
app.include_router(station_router, prefix="/station", tags=["station"])




if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host = "0.0.0.0", port = 8000)