from celery import Celery
from typing import Optional


class DiagnosticTaskManager:
    """
    Manages handing over tasks to the diagnostics service.
    """

    _celery: Optional[Celery] = None
    _diagnostic_task_name: str = "diagnostics.tasks.diagnose"

    def __init__(self):
        if not self._celery:
            raise AttributeError("Celery not configured.")

    @classmethod
    def set_celery(cls, celery: Celery | None):
        cls._celery = celery

    async def __call__(self, diagnosis_id):
        """Send a diagnosis id to the diagnostics backend for processing."""
        if self._celery is not None:
            self._celery.send_task(
                self._diagnostic_task_name, (str(diagnosis_id),)
            )
