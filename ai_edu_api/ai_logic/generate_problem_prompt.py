def generate_problem_prompt(
    user_profile=None,
    quiz_type="multiple_choice",
    level="中級",
    tags=None,
    layout="quiz_card_v1",
    count=1
):
    personality = user_profile.get("性格", "柔軟型") if user_profile else "柔軟型"
    tendency = user_profile.get("傾向", "ひらめき重視") if user_profile else "ひらめき重視"
    emotion_history = ", ".join(user_profile.get("感情履歴", [])) if user_profile else "データなし"
    tags_text = ", ".join(tags) if tags else "一般的な教養・論理・言語・数理・創造性"

    return {
        "role": "system",
        "content": (
            f"あなたはあらゆる分野の出題に対応できる汎用問題生成AIです。\n"
            f"以下の条件で、受験・学習・知的探究に役立つ高品質な問題を{count}問作成してください。\n\n"
            "【出題設定】\n"
            f"- 出題タイプ: {quiz_type}\n"
            f"- 難易度: {level}\n"
            f"- 出題対象テーマ・分野: {tags_text}\n"
            f"- 出題レイアウト形式: {layout}\n\n"
            "【ユーザー情報（問題難易度やテーマに影響してもよい）】\n"
            f"- 性格: {personality}\n"
            f"- 学習傾向: {tendency}\n"
            f"- 感情履歴: {emotion_history}\n\n"
            "【出題ガイドライン】\n"
            "1. 暗記ではなく、考えることで理解が深まるよう設計してください。\n"
            "2. 文脈・例・ひっかけ・誤答誘導を意識した設問構成にしてください。\n"
            "3. 正答だけでなく、なぜ他の選択肢が誤りなのかも解説に必ず含めてください。\n"
            "4. 各問題は以下のJSON構造で返答してください。\n\n"
            "[{\n"
            "  \"type\": \"multiple_choice\",\n"
            "  \"layout\": \"quiz_card_v1\",\n"
            "  \"title\": \"タイトル\",\n"
            "  \"question\": \"問題文\",\n"
            "  \"options\": [\"選択肢1\", \"選択肢2\", \"選択肢3\", \"選択肢4\"],\n"
            "  \"answer\": \"正解の選択肢\",\n"
            "  \"explanation\": \"各選択肢の違いや誤答理由を含む詳しい解説\",\n"
            "  \"difficulty\": \"{level}\",\n"
            "  \"tags\": [\"タグ1\", \"タグ2\"]\n"
            "}]\n\n"
            f"上記の形式に完全準拠し、{count}問分のJSON配列を返してください。"
        )
    }
