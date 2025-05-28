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
    allow_origins=["*"],  # 本番環境では適切なオリジンに制限することを推奨
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

def generate_problem_prompt(
    user_profile=None,
    quiz_type="multiple_choice",
    level="英検2級",
    tags=None,
    layout="quiz_card_v1",
    count=1
):
    profile_context = ""
    if user_profile:
        profile_context += (
            f"このユーザーは「{user_profile.get('性格', '未知')}」な性格で、"
            f"「{user_profile.get('傾向', '不明')}」な傾向があります。\n"
        )
    tags_text = ", ".join(tags) if tags else "一般的な文法・語彙"
    prompt = {
        "role": "system",
        "content": (
            f"{profile_context}"
            f"あなたは教育AIです。以下の条件で **{count}問** の問題を出題してください。\n"
            f"- 出題タイプ: {quiz_type}\n"
            f"- 難易度: {level}\n"
            f"- 出題範囲: {tags_text}\n"
            f"- レイアウトテンプレート: {layout}\n\n"
            "【出題ルール】\n"
            "1. 各問題には文脈・応用・誤答誘導を含めること。\n"
            "2. 出力形式は以下のJSON配列として返すこと：\n"
            "[\n"
            "  {\n"
            "    \"type\": \"multiple_choice\",\n"
            "    \"layout\": \"quiz_card_v1\",\n"
            "    \"title\": \"前置詞の使い分け\",\n"
            "    \"question\": \"...\",\n"
            "    \"options\": [\"...\", \"...\", \"...\", \"...\"],\n"
            "    \"answer\": \"...\",\n"
            "    \"explanation\": \"...\",\n"
            "    \"difficulty\": \"英検2級\",\n"
            "    \"tags\": [\"to不定詞\", \"前置詞\"]\n"
            "  }, ...\n"
            "]"
        )
    }
    return prompt

@app.post("/chat")
async def chat(request: Request):
    data = await request.json()
    messages = data.get("messages", [])
    mode = data.get("mode", "normal")
    model = data.get("model", "gpt-4o")
    user_id = data.get("user_id", None)
    question = messages[-1]["content"] if messages else ""
    context = json.dumps(messages[:-1]) if len(messages) > 1 else None
    quiz_type = data.get("quiz_type") or "multiple_choice"
    level = data.get("level") or "英検2級"
    tags = data.get("tags") or []
    layout = data.get("layout") or "quiz_card_v1"
    count = int(data.get("count", 1))

    # --- キャッシュ検索（count, layout, tagsも含めて一意化） ---
    cache_query = supabase.table("chat_qa_cache").select("*") \
        .eq("user_id", user_id) \
        .eq("model", model) \
        .eq("question", question) \
        .eq("count", count) \
        .eq("layout", layout)
    if tags:
        cache_query = cache_query.eq("tags", json.dumps(tags))
    if context:
        cache_query = cache_query.eq("context", context)
    cache_result = cache_query.execute()
    if cache_result.data and len(cache_result.data) > 0:
        cached = cache_result.data[0]
        return JSONResponse(content={
            "reply": cached["answer"],
            "emotion": cached.get("emotion", "ニュートラル"),
            "creative": cached.get("creative")
        }, media_type="application/json; charset=utf-8")

    # --- 出題意図の自動分類・プロファイル連携 ---
    user_profile = resident_ai.user_profiles.get(user_id)
    if any(x in question for x in ["問題生成", "問題を作って", "quiz", "問題を出して", "問題作成", "問題を自動生成"]):
        system_prompt = generate_problem_prompt(
            user_profile=user_profile,
            quiz_type=quiz_type,
            level=level,
            tags=tags,
            layout=layout,
            count=count
        )
    else:
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
        # 生成結果をキャッシュ保存
        supabase.table("chat_qa_cache").insert({
            "user_id": user_id,
            "model": model,
            "question": question,
            "context": context,
            "answer": reply,
            "emotion": emotion,
            "creative": creative_result
        }).execute()
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
