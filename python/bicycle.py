from fastapi import FastAPI
from station import router as station_router

# FastAPI객체 생성
app = FastAPI()

app.include_router(station_router, prefix="/station", tags=["station"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)