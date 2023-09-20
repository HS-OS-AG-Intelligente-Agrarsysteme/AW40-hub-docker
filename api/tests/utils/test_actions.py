from api.utils.actions import create_action_data


def test_create_action_data():
    assert isinstance(create_action_data(), list)
