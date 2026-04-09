def validate_task_input(data: dict) -> list[str]:
    """Validate task creation input. Returns list of error messages."""
    errors = []

    if not data:
        return ["Request body is required"]

    if "title" not in data:
        errors.append("Title is required")
    elif not isinstance(data["title"], str) or len(data["title"].strip()) == 0:
        errors.append("Title must be a non-empty string")
    elif len(data["title"]) > 200:
        errors.append("Title must be 200 characters or less")

    if "description" in data:
        if not isinstance(data["description"], str):
            errors.append("Description must be a string")
        elif len(data["description"]) > 1000:
            errors.append("Description must be 1000 characters or less")

    if "priority" in data:
        if not isinstance(data["priority"], int):
            errors.append("Priority must be an integer")
        elif data["priority"] < 1 or data["priority"] > 5:
            errors.append("Priority must be between 1 and 5")

    return errors
