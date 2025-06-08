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

def test_save_chat_history_to_supabase(resident_ai_agent):
    chat_id = "test_chat_id"
    messages = [
        {"role": "user", "content": "Hello!"},
        {"role": "assistant", "content": "Hi there!"}
    ]

    # No exception should be raised
    resident_ai_agent.save_chat_history_to_supabase(chat_id, messages)

def test_get_chat_history_from_supabase(resident_ai_agent):
    chat_id = "test_chat_id"

    # Retrieve chat history
    history = resident_ai_agent.get_chat_history_from_supabase(chat_id)

    # Ensure the history is a list
    assert isinstance(history, list)

def test_env_variables():
    assert os.environ.get("SUPABASE_URL") == "https://test.supabase.co"
    assert os.environ.get("SUPABASE_ANON_KEY") == "test_key"

@patch("ai_edu_api.supabase_logic.resident_ai_agent.create_client")
def test_mock_supabase_client(mock_create_client):
    mock_create_client.return_value = None
    resident_ai_agent = ResidentAIAgent()
    assert resident_ai_agent is not None
