from celery import Celery


class DiagnosticTaskManager:
    """
    Manages handing over tasks to the diagnostics service.
    """

    _celery: Celery = None
    _diagnostic_task_name: str = "diagnostics.tasks.diagnose"

    def __init__(self):
        if not self._celery:
            raise AttributeError("Celery not configured.")

    @classmethod
    def set_celery(cls, celery: Celery):
        cls._celery = celery

    async def __call__(self, diagnosis_id):
        """Send a diagnosis id to the diagnostics backend for processing."""
        self._celery.send_task(
            self._diagnostic_task_name, (str(diagnosis_id),)
        )
