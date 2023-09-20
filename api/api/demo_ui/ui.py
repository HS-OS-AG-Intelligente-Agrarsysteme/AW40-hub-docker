import httpx

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

app = FastAPI()
templates = Jinja2Templates(directory="api/demo_ui/templates")


@app.get("/{workshop_id}/cases/{case_id}/diag", response_class=HTMLResponse)
def diagnosis_report(request: Request, workshop_id: str, case_id: str):
    """Render an HTML report of a diagnosis."""
    try:
        # fetch diagnosis data from the api
        url = f"http://127.0.0.1:8000/v1/{workshop_id}/cases/{case_id}/diag"
        response = httpx.get(url)
        response.raise_for_status()
        diag = response.json()

        # for each log entry with attachment, replace the attachment id with
        # full attachment url
        for log_entry in diag["state_machine_log"]:
            attachment_id = log_entry["attachment"]
            if attachment_id is not None:
                attachment_url = f"{url}/attachments/{attachment_id}"
                log_entry["attachment"] = attachment_url

        return templates.TemplateResponse(
            "diagnosis_report.html",
            {
                "request": request,
                "case_id": diag["case_id"],
                "diag_status": diag["status"],
                "state_machine_log": diag["state_machine_log"],
                "todos": diag["todos"]
            }
        )
    except httpx.HTTPStatusError:
        return templates.TemplateResponse(
            "http_exception.html",
            {
                "request": request,
                "status_code": response.status_code,
                "details": response.json().get("detail")
            }
        )
