from typing import List

import httpx
from fastapi import FastAPI, Request, Form, UploadFile, Depends
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from . import template_filters

from .settings import settings

app = FastAPI()

app.mount(
    "/static", StaticFiles(directory="demo_ui/static"), name="static"
)

templates = Jinja2Templates(directory="demo_ui/templates")
templates.env.filters["schema_format"] = template_filters.schema_format
templates.env.filters["timestamp_format"] = template_filters.timestamp_format


@app.exception_handler(httpx.HTTPStatusError)
async def http_status_error_handler(request, exc):
    return templates.TemplateResponse(
        "http_exception.html",
        {
            "request": request,
            "status_code": exc.response.status_code,
            "details": exc.response.json().get("detail")
        }
    )


def get_cases_url(workshop_id: str) -> str:
    return f"{settings.hub_api_base_url}/{workshop_id}/cases"


def get_case_url(workshop_id: str, case_id: str) -> str:
    cases_url = get_cases_url(workshop_id)
    return f"{cases_url}/{case_id}"


def _get_data_url(
        workshop_id: str, case_id: str, data_type: str, data_id: str = None
) -> str:
    case_url = get_case_url(workshop_id, case_id)
    data_url = f"{case_url}/{data_type}"
    if data_id is not None:
        data_url = f"{data_url}/{data_id}"
    return data_url


def get_obd_data_url(
        workshop_id: str, case_id: str, data_id: str = None
) -> str:
    return _get_data_url(workshop_id, case_id, "obd_data", data_id)


def get_timeseries_data_url(
        workshop_id: str, case_id: str, data_id: str = None
) -> str:
    return _get_data_url(workshop_id, case_id, "timeseries_data", data_id)


def get_symptoms_url(
        workshop_id: str, case_id: str, data_id: str = None
) -> str:
    return _get_data_url(workshop_id, case_id, "symptoms", data_id)


def get_diagnosis_url(workshop_id: str, case_id: str) -> str:
    return _get_data_url(workshop_id, case_id, "diag", None)


def get_from_api(url: str) -> dict:
    response = httpx.get(url)
    response.raise_for_status()
    return response.json()


async def post_to_api(url: str, **kwargs) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.post(url, **kwargs)
        response.raise_for_status()
        return response.json()


def delete_via_api(url: str) -> dict:
    response = httpx.delete(url)
    return response.json()


def get_shared_url() -> str:
    return f"{settings.hub_api_base_url}/shared"


def get_components_url() -> str:
    shared_url = get_shared_url()
    return f"{shared_url}/known-components"


def get_shared_cases_url() -> str:
    shared_url = get_shared_url()
    return f"{shared_url}/cases"


def get_components(url: str = Depends(get_components_url)) -> List[str]:
    """Retrieve list of alphabetically sorted components from the API."""
    components = get_from_api(url)
    return sorted(components)


def get_workshops(url: str = Depends(get_shared_cases_url)) -> List[str]:
    """Retrieve list of alphabetically sorted workshops from the API."""
    # The API does not store any information about workshops outside of cases
    # ,yet. So for now, just retrieve list of all cases and extract workshop
    # ids
    cases = get_from_api(url)
    workshops = [case["workshop_id"] for case in cases]
    workshops = list(set(workshops))
    return sorted(workshops)


@app.get("/ui", response_class=HTMLResponse)
def login_get(request: Request, workshops: List[str] = Depends(get_workshops)):
    return templates.TemplateResponse(
        "login.html", {"request": request, "workshops": workshops}
    )


@app.post("/ui", response_class=RedirectResponse, status_code=303)
def login_post(request: Request, workshop_id: str = Form()):
    redirect_url = app.url_path_for("cases", workshop_id=workshop_id)
    return redirect_url


@app.get("/ui/{workshop_id}/cases", response_class=HTMLResponse)
def cases(request: Request, ressource_url: str = Depends(get_cases_url)):
    cases = get_from_api(ressource_url)
    for case in cases:
        if case["diagnosis_id"] is not None:
            case["diagnosis"] = get_from_api(
                get_diagnosis_url(
                    case["workshop_id"], case["_id"]
                )
            )
        else:
            case["diagnosis"] = {"status": "-"}
    return templates.TemplateResponse(
        "cases.html",
        {
            "request": request,
            "cases": cases
        }
    )


@app.get("/ui/{workshop_id}/cases/new", response_class=HTMLResponse)
def new_case_get(request: Request):
    return templates.TemplateResponse(
        "new_case.html",
        {
            "request": request
        }
    )


@app.post(
    "/ui/{workshop_id}/cases/new",
    response_class=RedirectResponse, status_code=303
)
async def new_case_post(
        request: Request, ressource_url: str = Depends(get_cases_url)
):
    form = await request.form()
    # remove empty fields
    form = {k: v for k, v in form.items() if v}
    case = await post_to_api(ressource_url, json=dict(form))
    redirect_url = app.url_path_for(
        "case", workshop_id=case["workshop_id"], case_id=case["_id"]
    )
    return redirect_url


@app.get("/ui/{workshop_id}/cases/{case_id}", response_class=HTMLResponse)
def case(request: Request, ressource_url: str = Depends(get_case_url)):
    case = get_from_api(ressource_url)
    if case["diagnosis_id"] is not None:
        # get diagnosis and embed in case
        diagnosis = get_from_api(
            get_diagnosis_url(
                case["workshop_id"], case["_id"]
            )
        )
        case["diagnosis"] = diagnosis

    return templates.TemplateResponse(
        "case.html",
        {
            "request": request,
            "case": case
        }
    )


@app.get(
    "/ui/{workshop_id}/cases/{case_id}/delete",
    response_class=RedirectResponse,
    status_code=303
)
def case_delete_get(
        request: Request, ressource_url: str = Depends(get_case_url)
):
    delete_via_api(ressource_url)
    redirect_url = app.url_path_for(
        "cases", workshop_id=request.path_params["workshop_id"]
    )
    return redirect_url


@app.get(
    "/ui/{workshop_id}/cases/{case_id}/obd_data/new",
    response_class=HTMLResponse
)
def new_obd_data_get(request: Request):
    return templates.TemplateResponse(
        "new_obd_data.html", {"request": request}
    )


@app.post(
    "/ui/{workshop_id}/cases/{case_id}/obd_data/new",
    response_class=RedirectResponse,
    status_code=303
)
async def new_obd_data_post(
        request: Request,
        ressource_url: str = Depends(get_obd_data_url),
        dtcs_text: str = Form(default=None),
        vcds_file: UploadFile = None
):
    if dtcs_text:
        dtcs = dtcs_text.split("\r\n")
        obd_data = {"dtcs": dtcs}
        case = await post_to_api(ressource_url, json=obd_data)
    if vcds_file:
        ressource_url = f"{ressource_url}/upload/vcds"
        case = await post_to_api(
            ressource_url,
            files={"upload": (vcds_file.filename, vcds_file.file)}
        )

    new_data_id = case["obd_data"][-1]["data_id"]
    redirect_url = app.url_path_for(
        "obd_data",
        workshop_id=case["workshop_id"],
        case_id=case["_id"],
        data_id=new_data_id
    )
    return redirect_url


@app.get(
    "/ui/{workshop_id}/cases/{case_id}/obd_data/{data_id}",
    response_class=HTMLResponse
)
def obd_data(
        request: Request,
        ressource_url: str = Depends(get_obd_data_url),
        dtc: str = None
):
    obd_data = get_from_api(ressource_url)
    return templates.TemplateResponse(
        "obd_data.html",
        {
            "request": request,
            "obd_data": obd_data
        }
    )


@app.get(
    "/ui/{workshop_id}/cases/{case_id}/obd_data/{data_id}/delete",
    response_class=RedirectResponse,
    status_code=303
)
def obd_data_delete_get(
        request: Request, ressource_url: str = Depends(get_obd_data_url)
):
    delete_via_api(ressource_url)
    redirect_url = app.url_path_for(
        "case",
        workshop_id=request.path_params["workshop_id"],
        case_id=request.path_params["case_id"]
    )
    return redirect_url


@app.get(
    "/ui/{workshop_id}/cases/{case_id}/timeseries_data/new",
    response_class=HTMLResponse
)
def new_timeseries_data_get(
        request: Request,
        components: List[str] = Depends(get_components),
        suggested_component: str = ""

):
    return templates.TemplateResponse(
        "new_timeseries_data.html",
        {
            "request": request,
            "components": components,
            "suggested_component": suggested_component
        }
    )


@app.post(
    "/ui/{workshop_id}/cases/{case_id}/timeseries_data/new",
    response_class=RedirectResponse,
    status_code=303
)
async def new_timeseries_data_post(
        request: Request,
        ressource_url: str = Depends(get_timeseries_data_url)
):
    form = await request.form()
    form = dict(form)
    form["file_format"] = "Picoscope CSV"
    picoscope_file = form.pop("picoscope_file")
    ressource_url = f"{ressource_url}/upload/picoscope"
    case = await post_to_api(
        ressource_url,
        files={"upload": (picoscope_file.filename, picoscope_file.file)},
        data=form
    )

    new_data_id = case["timeseries_data"][-1]["data_id"]
    redirect_url = app.url_path_for(
        "timeseries_data",
        workshop_id=case["workshop_id"],
        case_id=case["_id"],
        data_id=new_data_id
    )
    return redirect_url


@app.get(
    "/ui/{workshop_id}/cases/{case_id}/timeseries_data/{data_id}",
    response_class=HTMLResponse
)
def timeseries_data(
        request: Request,
        ressource_url: str = Depends(get_timeseries_data_url),
):
    timeseries_data = get_from_api(ressource_url)
    signal_url = f"{ressource_url}/signal"
    signal = get_from_api(signal_url)
    # convert signal to 2d array with columns 'Zeit' and 'Signal'
    sr = timeseries_data["sampling_rate"]
    signal = [[i/sr, v] for i, v in enumerate(signal)]

    return templates.TemplateResponse(
        "timeseries_data.html",
        {
            "request": request,
            "timeseries_data": timeseries_data,
            "signal": signal
        }
    )


@app.get(
    "/ui/{workshop_id}/cases/{case_id}/timeseries_data/{data_id}/delete",
    response_class=RedirectResponse,
    status_code=303
)
def timeseries_data_delete_get(
        request: Request, ressource_url: str = Depends(get_timeseries_data_url)
):
    delete_via_api(ressource_url)
    redirect_url = app.url_path_for(
        "case",
        workshop_id=request.path_params["workshop_id"],
        case_id=request.path_params["case_id"]
    )
    return redirect_url


@app.get(
    "/ui/{workshop_id}/cases/{case_id}/symptoms/new",
    response_class=HTMLResponse
)
def new_symptom_get(
        request: Request,
        components: List[str] = Depends(get_components),
        suggested_component: str = ""
):
    return templates.TemplateResponse(
        "new_symptom.html",
        {
            "request": request,
            "components": components,
            "suggested_component": suggested_component
        }
    )


@app.post(
    "/ui/{workshop_id}/cases/{case_id}/symptoms/new",
    response_class=RedirectResponse,
    status_code=303
)
async def new_symptom_post(
        request: Request,
        ressource_url: str = Depends(get_symptoms_url)
):
    form = await request.form()
    case = await post_to_api(ressource_url, json=dict(form))
    redirect_url = app.url_path_for(
        "case", workshop_id=case["workshop_id"], case_id=case["_id"]
    )
    return redirect_url


@app.get(
    "/ui/{workshop_id}/cases/{case_id}/symptoms/{data_id}/delete",
    response_class=RedirectResponse,
    status_code=303
)
def symptom_delete_get(
        request: Request, ressource_url: str = Depends(get_symptoms_url)
):
    delete_via_api(ressource_url)
    redirect_url = app.url_path_for(
        "case",
        workshop_id=request.path_params["workshop_id"],
        case_id=request.path_params["case_id"]
    )
    return redirect_url


@app.post(
    "/ui/{workshop_id}/cases/{case_id}/diag",
    response_class=RedirectResponse,
    status_code=303
)
async def start_diagnosis(
        request: Request,
        ressource_url: str = Depends(get_diagnosis_url)
):
    await post_to_api(ressource_url)
    redirect_url = app.url_path_for(
        "case",
        workshop_id=request.path_params["workshop_id"],
        case_id=request.path_params["case_id"]
    )
    return redirect_url


@app.get("/ui/{workshop_id}/cases/{case_id}/diag", response_class=HTMLResponse)
def diagnosis_report(
        request: Request, ressource_url: str = Depends(get_diagnosis_url)
):
    diag = get_from_api(ressource_url)

    # for each log entry with attachment, replace the attachment id with
    # full attachment url
    for log_entry in diag["state_machine_log"]:
        attachment_id = log_entry["attachment"]
        if attachment_id is not None:
            attachment_url = f"{ressource_url}/attachments/{attachment_id}"
            attachment_url = attachment_url.replace(
                settings.hub_api_base_url, settings.hub_api_host_url
            )
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


@app.get(
    "/ui/{workshop_id}/cases/{case_id}/diagnosis/delete",
    response_class=RedirectResponse,
    status_code=303
)
def diagnosis_delete_get(
        request: Request, ressource_url: str = Depends(get_diagnosis_url)
):
    delete_via_api(ressource_url)
    redirect_url = app.url_path_for(
        "case",
        workshop_id=request.path_params["workshop_id"],
        case_id=request.path_params["case_id"]
    )
    return redirect_url
