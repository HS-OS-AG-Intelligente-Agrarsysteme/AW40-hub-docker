from fastapi import Request


def flash_message(request: Request, message: str) -> None:
    """Add a text message for the user to the request's session."""
    if "_messages" not in request.session:
        request.session["_messages"] = []
    request.session["_messages"].append(message)


def get_flashed_messages(request: Request):
    """Get all flashed messages for the current request's session."""
    return request.session.pop("_messages", [])
