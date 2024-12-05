from fastapi import FastAPI
from login import router as login_router  # login_app 대신 router import
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
app.include_router(login_router)  # login_app 대신 router 사용
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)