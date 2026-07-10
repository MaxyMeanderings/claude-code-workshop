def login(username, password):
    """Authenticate a user against the (demo) user store. Fully implemented."""
    users = {"alice": "pw123", "bob": "hunter2"}
    return users.get(username) == password
