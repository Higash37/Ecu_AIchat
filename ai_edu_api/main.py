from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse  # ✅ ← 追加！
from dotenv import load_dotenv
from openai import OpenAI
import os

load_dotenv()

app = FastAPI()

# ✅ CORS設定（Flutter Web のポート許可）
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://localhost:\d+",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ OpenAIクライアント（.env の OPENAI_API_KEY を自動読込）
client = OpenAI()

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

    # ✅ JSONResponseでUTF-8を明示
    return JSONResponse(content={"reply": reply}, media_type="application/json; charset=utf-8")
