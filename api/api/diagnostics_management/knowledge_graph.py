from typing import Optional


class KnowledgeGraph:
    kg_url: Optional[str] = None
    obd_dataset_name: str = "OBD"

    @classmethod
    def set_kg_url(cls, url: str | None):
        """Set knowledge graph (root) url"""
        cls.kg_url = url

    @classmethod
    def get_obd_url(cls) -> str | None:
        """Get url of OBD dataset for configured knowledge graph."""
        if cls.kg_url is None:
            return None
        kg_obd_url = f"{cls.kg_url}/{cls.obd_dataset_name}"
        return kg_obd_url
