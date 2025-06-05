from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, StreamingResponse
from openai import OpenAI
from supabase import create_client, Client
import os
import pathlib
import json
from threading import Thread
import time
from ai_scripts.generate_problem_prompt import generate_problem_prompt
from ai_scripts.resident_ai_agent import ResidentAIAgent
from ai_scripts.chat_endpoints import chat_endpoint_logic, chat_stream_endpoint_logic

# プロジェクトルートディレクトリのパスを取得（今後使う場合のみ）
root_dir = pathlib.Path(__file__).parent.parent.absolute()

app = FastAPI()

# ✅ CORS設定（Flutter Web・モバイル・本番環境すべて許可）
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "*", 
        "https://ecu-a-ichat-dvsd.vercel.app",  # メインURL
        "https://ecu-aichat-frontend.onrender.com",  # RenderデプロイURL
        "https://ecu-a-ichat-dvsd-git-main-higash37s-projects.vercel.app",  # ブランチURL
        "https://ecu-a-ichat-dvsd-28ij9jftt-higash37s-projects.vercel.app"  # デプロイURL
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ OpenAIクライアント（Renderの環境変数から読み込み）
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

# Supabaseクライアント
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_ANON_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ResidentAIAgentインスタンスの作成
resident_ai = ResidentAIAgent()

@app.get("/")
async def health_check():
    """
    スリープ防止用のヘルスチェックエンドポイント
    定期的なping用に使用します
    """
    return {"status": "ok", "message": "API is running"}

@app.post("/chat")
async def chat(request: Request):
    data = await request.json()
    chat_id = data.get("chat_id")
    messages = data.get("messages", [])

    # Supabaseから履歴を取得して結合
    past_messages = resident_ai.get_chat_history_from_supabase(chat_id) if chat_id else []
    data["messages"] = past_messages + messages

    # エンドポイント処理へ渡す
    return chat_endpoint_logic(data)

@app.post("/chat/stream")
async def chat_stream(request: Request):
    data = await request.json()
    return chat_stream_endpoint_logic(data)
