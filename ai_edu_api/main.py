from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, StreamingResponse
from dotenv import load_dotenv
from openai import OpenAI
import os
import pathlib
import json
from threading import Thread
import time

# プロジェクトルートディレクトリのパスを取得
root_dir = pathlib.Path(__file__).parent.parent.absolute()
# ルートディレクトリの.envファイルを読み込む
load_dotenv(os.path.join(root_dir, '.env'))

app = FastAPI()

# ✅ CORS設定（Flutter Web・モバイル・本番環境すべて許可）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 本番環境では適切なオリジンに制限することを推奨
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ OpenAIクライアント（.envファイルからOPENAI_API_KEYを読み込み）
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

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
        # TODO: SupabaseやDBから全ユーザーのチャット履歴・頻度・時間帯・速度などを取得
        # 例: self.user_profiles[user_id] = {"性格": ..., "傾向": ..., "感情履歴": ...}
        print("[ResidentAIAgent] ユーザープロファイル・知識グラフを自動更新しました")
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

@app.post("/chat")
async def chat(request: Request):
    data = await request.json()
    messages = data.get("messages", [])
    mode = data.get("mode", "normal")
    model = data.get("model", "gpt-4o")
    user_id = data.get("user_id", None)

    # Function callingで感情ラベルも取得
    system_prompt = {
        "role": "system",
        "content": "あなたは教育AIアシスタントです。ユーザーの発言やAIの返答の感情を一言でラベル化してください（例: ポジティブ, ネガティブ, 喜び, 怒り, 驚き, 悲しみ, ニュートラル など）。返答と感情ラベルをJSON形式で返してください。例: {\"reply\": \"...\", \"emotion\": \"ポジティブ\"}"
    }
    full_messages = [system_prompt] + messages

    # --- ResidentAIによる独自発想・仮説生成 ---
    creative_result = None
    if mode == "creative":
        creative_result = resident_ai.creative_thinking(messages[-1]["content"] if messages else "", full_messages)

    if model == "higash-ai":
        # ResidentAIのみで応答
        # ユーザーのプロファイルを更新
        if user_id:
            # TODO: 実際はDBから履歴取得
            resident_ai.analyze_user(user_id, messages)
        creative_result = resident_ai.creative_thinking(messages[-1]["content"] if messages else "", full_messages, user_id=user_id)
        reply = creative_result["idea"] if creative_result and "idea" in creative_result else "ResidentAI: 準備中です。"
        emotion = "ニュートラル"
        return JSONResponse(content={
            "reply": reply,
            "emotion": emotion,
            "creative": creative_result
        }, media_type="application/json; charset=utf-8")
    else:
        # 通常のOpenAI（gpt-4o等）
        response = client.chat.completions.create(
            model=model,
            messages=full_messages,
            response_format={"type": "json_object"}
        )
        try:
            result = json.loads(response.choices[0].message.content)
            reply = result.get("reply", "")
            emotion = result.get("emotion", "ニュートラル")
        except Exception:
            reply = response.choices[0].message.content
            emotion = "ニュートラル"
        print("GPT reply:", reply, "emotion:", emotion)
        return JSONResponse(content={
            "reply": reply,
            "emotion": emotion,
            "creative": creative_result
        }, media_type="application/json; charset=utf-8")

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
