import pytest
from ai_edu_api.api_endpoints.chat_endpoints import chat_endpoint_logic
from unittest.mock import patch

@pytest.fixture
def mock_resident_ai_agent():
    with patch("ai_edu_api.supabase_logic.resident_ai_agent.ResidentAIAgent") as MockAgent:
        instance = MockAgent.return_value
        instance.get_chat_history_from_supabase.return_value = [
            {"role": "user", "content": "Hello!"},
            {"role": "assistant", "content": "Hi there!"}
        ]
        yield instance

def test_full_messages_structure(mock_resident_ai_agent):
    chat_id = "test_chat_id"
    messages = [{"role": "user", "content": "How are you?"}]

    result = chat_endpoint_logic(chat_id, messages)

    assert "以下はこれまでの会話の文脈です" in result[0]["content"]
    assert len(result) == 3
