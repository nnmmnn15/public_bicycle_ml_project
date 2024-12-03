from fastapi import FastAPI

# FastAPI객체 생성
app = FastAPI()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)