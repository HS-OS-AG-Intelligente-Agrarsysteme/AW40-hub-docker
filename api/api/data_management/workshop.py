from beanie import Document


class Workshop(Document):

    class Settings:
        name = "workshops"

    id: str
