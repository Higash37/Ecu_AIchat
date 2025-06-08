from supabase import create_client, Client
import os
import json

# Load environment variables from env.json
env_path = os.path.join(os.path.dirname(__file__), '../../env.json')
if os.path.exists(env_path):
    with open(env_path, 'r') as env_file:
        env_data = json.load(env_file)
        os.environ["SUPABASE_URL"] = env_data.get("SUPABASE_URL", "")
        os.environ["SUPABASE_ANON_KEY"] = env_data.get("SUPABASE_ANON_KEY", "")

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_ANON_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Load OpenAI API key
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")

# Example usage of OpenAI API key
print(f"OpenAI API Key: {OPENAI_API_KEY}")

class ResidentAIAgent:
    def __init__(self):
        self.user_profiles = {}

    def analyze_user(self, user_id, chat_history):
        profile = {
            "性格": "おおらか",
            "傾向": "夜型・返信早い・ポジティブ多め",
            "感情履歴": ["喜び", "驚き", "ニュートラル"]
        }
        self.user_profiles[user_id] = profile
        return profile

    def creative_thinking(self, user_input, context, user_id=None):
        profile = self.user_profiles.get(user_id, None)
        return {
            "creative": True,
            "idea": f"{user_id}さんは{profile['性格'] if profile else 'ユニーク'}な方なので、こういう提案も面白いかも！",
            "reasoning": f"過去の傾向: {profile['傾向'] if profile else 'データ不足'}"
        } if user_id else None

    def save_chat_history_to_supabase(self, chat_id: str, messages: list):
        if not chat_id or not messages:
            print(f"[ResidentAI] Invalid chat_id or empty messages: chat_id={chat_id}, messages={messages}")
            return

        rows = []
        for msg in messages:
            if not isinstance(msg, dict) or "role" not in msg or "content" not in msg:
                print(f"[ResidentAI] Skipping invalid message format: {msg}")
                continue
            rows.append({
                "chat_id": chat_id,
                "sender": msg["role"],
                "content": msg["content"]
            })

        try:
            supabase.table("messages").insert(rows).execute()
            print(f"[ResidentAI] Successfully saved messages to Supabase: {rows}")
        except Exception as e:
            print(f"[ResidentAI] Error saving messages to Supabase: {e}")

    def get_chat_history_from_supabase(self, chat_id: str):
        if not chat_id:
            print(f"[ResidentAI] Invalid chat_id: {chat_id}")
            return []

        try:
            response = supabase.table("message")\
                .select("sender, content")\
                .eq("chat_id", chat_id)\
                .order("created_at")\
                .execute()
            data = response.data if hasattr(response, "data") else response
            print(f"[ResidentAI] Retrieved chat history: {data}")
            for msg in data:
                print(f"[ResidentAI] Message details - sender: {msg.get('sender')}, content: {msg.get('content')}")
            return [
                {"role": msg["sender"], "content": msg["content"]}
                for msg in data if "sender" in msg and "content" in msg
            ]
        except Exception as e:
            print(f"[ResidentAI] Error retrieving chat history: {e}")
            return []
