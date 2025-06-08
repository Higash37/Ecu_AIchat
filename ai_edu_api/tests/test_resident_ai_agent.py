import os
from unittest.mock import patch
import pytest

@pytest.fixture(scope="module", autouse=True)
def mock_env_variables():
    os.environ["SUPABASE_URL"] = "https://test.supabase.co"
    os.environ["SUPABASE_ANON_KEY"] = "test_key"
    yield
    del os.environ["SUPABASE_URL"]
    del os.environ["SUPABASE_ANON_KEY"]

from ai_edu_api.supabase_logic.resident_ai_agent import ResidentAIAgent

@pytest.fixture
def resident_ai_agent():
    return ResidentAIAgent()

def test_analyze_user(resident_ai_agent):
    user_id = "test_user"
    chat_history = [
        {"content": "Hello!"},
        {"content": "How are you?"}
    ]

    profile = resident_ai_agent.analyze_user(user_id, chat_history)

    assert profile is not None
    assert profile["性格"] == "おおらか"
    assert "Hello!" in profile["感情履歴"]
