from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
from openai import OpenAI
import os
import pathlib

# プロジェクトルートディレクトリのパスを取得
root_dir = pathlib.Path(__file__).parent.parent.absolute()
# ルートディレクトリの.envファイルを読み込む
load_dotenv(os.path.join(root_dir, '.env'))

app = FastAPI()

# ✅ CORS設定（Flutter Web のポート許可）
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://localhost:\d+",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ OpenAIクライアント（.envファイルからOPENAI_API_KEYを読み込み）
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

@app.post("/chat")
async def chat(request: Request):
    data = await request.json()
    messages = data.get("messages", [])

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=messages
    )

    reply = response.choices[0].message.content
    print("GPT reply:", reply)

    return JSONResponse(content={"reply": reply}, media_type="application/json; charset=utf-8")
