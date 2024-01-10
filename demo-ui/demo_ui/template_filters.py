from datetime import datetime

"""
Custom Jinja2 Filters to format raw values obtained via the API.
See https://jinja.palletsprojects.com/en/3.1.x/api/#writing-filters
"""


def schema_format(value, map_key):
    occasion_map = {
        "problem_defect": "Problem / Defekt",
        "service_routine": "Service / Routine"
    }
    timeseries_data_label_map = {
        "unknown": "Unbekannt",
        "norm": "Normalbild",
        "anomaly": "Anomalie"
    }
    symptom_label_map = {
        "unknown": "Unklar",
        "ok": "Funktionsfähig",
        "defect": "Defekt"
    }
    diagnosis_status_map = {
        "scheduled": "Gestartet",
        "action_required": "Aktion erforderlich",
        "processing": "In Bearbeitung",
        "finished": "Abgeschlossen"
    }
    maps = {
        "occasion": occasion_map,
        "timeseries_data_label": timeseries_data_label_map,
        "symptom_label": symptom_label_map,
        "diagnosis_status": diagnosis_status_map
    }
    map = maps.get(map_key)
    if not map:
        return value
    return map.get(value, value)


def timestamp_format(value):
    ts = datetime.fromisoformat(value)
    return ts.strftime(
        "%d.%m.%Y %H:%M:%S"
    )
