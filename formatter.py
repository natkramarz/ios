from datetime import date
from typing import List, Tuple

from parse import Table, Column


def __column_as_json(field: Column):
    return {
        "fullName": field.full_name,
        "description": field.description if field.description else ""
    }


def __table_as_json(table: Table, url: str, start_time: date):
    return {
        "datasetTable": table.datasetAndName(),
        "spreadsheetUrl": url,
        "fetchedAt": start_time.isoformat(),
        "description": table.description if table.description else "",
        "fields": {column.full_name: __column_as_json(column) for column in
                   table.columns}
    }


def format_as_json(tables: List[Tuple[Table, str]],
    fetch_date: date):
    return {table.datasetAndName(): __table_as_json(table, url, fetch_date) for
            table, url in tables}
