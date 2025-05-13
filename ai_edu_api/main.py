from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from openai import OpenAI
import os

app = FastAPI()

# ✅ CORS設定（Flutter Web のポート許可）
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://localhost:\d+",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ OpenAIクライアント（Docker側で環境変数として渡される前提）
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
