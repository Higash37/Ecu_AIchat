import os
import json

# Load environment variables from env.json
env_path = os.path.join(os.path.dirname(__file__), '../../env.json')
if os.path.exists(env_path):
    with open(env_path, 'r') as env_file:
        env_data = json.load(env_file)
        # Supabase関連の環境変数を削除
        # os.environ["SUPABASE_URL"] = env_data.get("SUPABASE_URL", "")
        # os.environ["SUPABASE_ANON_KEY"] = env_data.get("SUPABASE_ANON_KEY", "")

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_ANON_KEY")

# Load OpenAI API key
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")

# Example usage of OpenAI API key
print(f"OpenAI API Key: {OPENAI_API_KEY}")

class ResidentAIAgent:
    def __init__(self):
        self.user_profiles = {}

    def analyze_user(self, user_id, chat_history):
        if not chat_history:
            print(f"[ResidentAI] No chat history provided for user_id: {user_id}")
            return None

        # Example logic to analyze chat history and update user profile
        profile = {
            "性格": "おおらか",
            "傾向": "夜型・返信早い・ポジティブ多め",
            "感情履歴": [msg.get("content", "") for msg in chat_history if "content" in msg]
        }
        self.user_profiles[user_id] = profile
        print(f"[ResidentAI] Updated profile for user_id {user_id}: {profile}")
        return profile

    def creative_thinking(self, user_input, context, user_id=None):
        profile = self.user_profiles.get(user_id, None)
        return {
            "creative": True,
            "idea": f"{user_id}さんは{profile['性格'] if profile else 'ユニーク'}な方なので、こういう提案も面白いかも！",
            "reasoning": f"過去の傾向: {profile['傾向'] if profile else 'データ不足'}"
        } if user_id else None
