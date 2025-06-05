from fastapi.responses import JSONResponse, StreamingResponse
import json
from ai_scripts.generate_problem_prompt import generate_problem_prompt
from ai_scripts.resident_ai_agent import ResidentAIAgent
from openai import OpenAI
import os
import logging

logging.basicConfig(level=logging.DEBUG)

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
resident_ai = ResidentAIAgent()

def chat_endpoint_logic(data):
    logging.debug(f"Received data: {data}")
    messages = data.get("messages", [])
    chat_id = data.get("chat_id")
    mode = data.get("mode", "normal")
    model = data.get("model", "gpt-4o")
    user_id = data.get("user_id", None)
    question = messages[-1]["content"] if messages else ""
    quiz_type = data.get("quiz_type", "multiple_choice")
    level = data.get("level", "中級")
    tags = data.get("tags", [])
    layout = data.get("layout", "quiz_card_v1")
    count = int(data.get("count", 1))

    if not chat_id or not user_id:
        logging.error("Missing chat_id or user_id in request.")
        return JSONResponse(status_code=400, content={"error": "Missing chat_id or user_id."})

    user_profile = resident_ai.user_profiles.get(user_id)

    is_quiz_request = any(x in question for x in [
        "問題生成", "問題を作って", "quiz", "問題を出して", "問題作成", "問題を自動生成"
    ])

    if is_quiz_request:
        # 出題専用プロンプトを使用、履歴は混ぜない
        system_prompt = generate_problem_prompt(
            user_profile=user_profile,
            quiz_type=quiz_type,
            level=level,
            tags=tags,
            layout=layout,
            count=count
        )
        full_messages = [system_prompt]
    else:
        # 履歴を活かした通常会話
        resident_messages = resident_ai.get_chat_history_from_supabase(chat_id) if chat_id else []
        openai_messages = resident_ai.get_openai_history(chat_id) if chat_id else []
        context_messages = "\n".join([msg["content"] for msg in resident_messages + openai_messages])
        system_prompt = {
            "role": "system",
            "content": f"以下はこれまでの会話の文脈です:\n{context_messages}\nこれを踏まえて、以下の質問に答えてください。"
        }
        full_messages = [system_prompt] + resident_messages + openai_messages + messages

    if chat_id and not is_quiz_request:
        resident_ai.save_chat_history_to_supabase(chat_id, full_messages)

    # Resident AI モード
    creative_result = None
    if mode == "creative":
        creative_result = resident_ai.creative_thinking(
            question,
            full_messages,
            user_id=user_id
        )

    if model == "higash-ai":
        if user_id:
            resident_ai.analyze_user(user_id, messages)
        creative_result = resident_ai.creative_thinking(
            question,
            full_messages,
            user_id=user_id
        )
        reply = creative_result.get("idea", "ResidentAI: 準備中です。")
        return JSONResponse(content={
            "reply": reply,
            "emotion": "ニュートラル",
            "creative": creative_result
        }, media_type="application/json; charset=utf-8")

    # GPT-4など通常モデル
    response = client.chat.completions.create(
        model=model,
        messages=full_messages,
        temperature=0.7,
        response_format={"type": "json_object"}
    )

    try:
        result = json.loads(response.choices[0].message.content)
        reply = result.get("reply", "")
        emotion = result.get("emotion", "ニュートラル")
    except Exception:
        reply = response.choices[0].message.content
        emotion = "ニュートラル"

    return JSONResponse(content={
        "reply": reply,
        "emotion": emotion,
        "creative": creative_result
    }, media_type="application/json; charset=utf-8")


def chat_stream_endpoint_logic(data):
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
