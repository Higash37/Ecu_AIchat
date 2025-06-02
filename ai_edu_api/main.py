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

# プロジェクトルートディレクトリのパスを取得（今後使う場合のみ）
root_dir = pathlib.Path(__file__).parent.parent.absolute()

app = FastAPI()

# ✅ CORS設定（Flutter Web・モバイル・本番環境すべて許可）
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "*",  # 全てのローカルホストURLを許可
        "https://ecu-a-ichat-dvsd.vercel.app",  # メインURL
        "https://ecu-aichat-frontend.onrender.com",  # RenderデプロイURL
        "https://ecu-a-ichat-dvsd-git-main-higash37s-projects.vercel.app",  # ブランチURL
        "https://ecu-a-ichat-dvsd-28ij9jftt-higash37s-projects.vercel.app"  # デプロイURL
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ OpenAIクライアント（.envファイルからOPENAI_API_KEYを読み込み）
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

# Supabaseクライアント
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_ANON_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

print(f"[デバッグ] Supabaseクライアントの状態: URL={SUPABASE_URL}, KEY={SUPABASE_KEY}")


# --- 独自AIエージェント: DBやOpenAIの裏で“住み着く”知識グラフ・推論エンジン ---
class ResidentAIAgent:
    def __init__(self):
        self.knowledge_graph = {}
        self.user_profiles = {}  # user_idごとの性格・傾向・感情履歴
        self.last_update = time.time()
        self.running = True
        self.thread = Thread(target=self._background_loop, daemon=True)
        self.thread.start()

    def _background_loop(self):
        while self.running:
            self.update_knowledge()
            time.sleep(60)  # 1分ごとに知識グラフを更新

    def update_knowledge(self):
        try:
            # Supabaseからデータを取得
            response = supabase.table("chat_history").select("*").execute()
            if response.data:
                for record in response.data:
                    user_id = record.get("user_id")
                    if user_id not in self.user_profiles:
                        self.user_profiles[user_id] = {"性格": [], "傾向": [], "感情履歴": []}
                    # データを解析してプロファイルに追加
                    self.user_profiles[user_id]["感情履歴"].append(record.get("emotion"))

            print("[ResidentAIAgent] ユーザープロファイル・知識グラフを自動更新しました")
        except Exception as e:
            print(f"[ResidentAIAgent] 知識グラフの更新中にエラーが発生しました: {e}")

        self.last_update = time.time()

    def analyze_user(self, user_id, chat_history):
        # ユーザーの話し方・頻度・時間帯・速度・感情傾向などを解析し、性格や特徴を推定
        # TODO: 実際の解析ロジックを実装
        profile = {
            "性格": "おおらか",
            "傾向": "夜型・返信早い・ポジティブ多め",
            "感情履歴": ["喜び", "驚き", "ニュートラル"]
        }
        self.user_profiles[user_id] = profile
        return profile

    def creative_thinking(self, user_input, context, user_id=None):
        # ユーザーごとの性格・傾向・感情を参照し、独自の仮説や“この人らしい”提案を生成
        profile = self.user_profiles.get(user_id, None)
        # TODO: 実際の連想・仮説生成ロジック
        return {
            "creative": True,
            "idea": f"{user_id}さんは{profile['性格'] if profile else 'ユニーク'}な方なので、こういう提案も面白いかも！",
            "reasoning": f"過去の傾向: {profile['傾向'] if profile else 'データ不足'}"
        } if user_id else None

resident_ai = ResidentAIAgent()

@app.get("/")
async def health_check():
    """
    スリープ防止用のヘルスチェックエンドポイント
    定期的なping用に使用します
    """
    return {"status": "ok", "message": "API is running"}


@app.post("/chat/stream")
async def chat_stream(request: Request):
    data = await request.json()
    messages = data.get("messages", [])

    def event_stream():
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=messages,
            stream=True
        )
        for chunk in response:
            delta = chunk.choices[0].delta.content if chunk.choices[0].delta else None
            if delta:
                yield f"data: {json.dumps({'token': delta})}\n\n"
        yield "data: [DONE]\n\n"

    return StreamingResponse(event_stream(), media_type="text/event-stream")

@app.post("/generate_title")
async def generate_title(request: Request):
    data = await request.json()
    initial_message = data.get("initial_message", "")

    if not initial_message:
        return JSONResponse(content={"error": "Initial message is required."}, status_code=400)

    # OpenAI APIを使用してタイトルを生成
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "user", "content": f"以下のメッセージに基づいてチャットのタイトルを生成してください: {initial_message}"}
        ],
        max_tokens=10
    )
    title = response.choices[0].message.content.strip()

    # Supabaseにタイトルを保存
    chat_id = data.get("chat_id")
    if chat_id:
        supabase.table("chats").update({"title": title}).eq("id", chat_id).execute()

    return JSONResponse(content={"title": title}, status_code=200)
