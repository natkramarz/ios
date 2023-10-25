from datetime import date
from typing import List, Tuple

from parse import Table, Column


def _column_attribute(column: Column):
    column_attributes = {}
    if column.full_name:
        column_attributes['fullName'] = column.full_name
    if column.description:
        column_attributes['description'] = column.description
    if column.enumeration:
        column_attributes["enumeration"] = column.enumeration
    if column.data_type:
        column_attributes["dataType"] = column.data_type
    if column.nullable:
        column_attributes["isNullable"] = column.nullable
    if column.anonymize:
        column_attributes["isAnonymized"] = column.anonymize
    if column.example_value:
        column_attributes["exampleValue"] = column.example_value
    return column_attributes


def _columns_attributes(columns: List[Column]):
    return [_column_attribute(column) for column in columns]


def _table_as_json(table: Table, url: str, start_time: date):
    table_attributes = {
        "datasetTable": table.dataset_and_name(),
        "spreadsheetUrl": url,
        "uploadDate": start_time.isoformat(),
        "description": table.description if table.description else "",
        "columns": _columns_attributes(table.columns)
    }

    if table.classification:
        table_attributes['classification'] = table.classification
    if table.type:
        table_attributes['type'] = table.type
    if table.frequency:
        table_attributes['frequency'] = table.frequency
    if table.version:
        table_attributes['version'] = table.version

    return table_attributes


def format_as_json(tables: List[Tuple[Table, str]], fetch_date: date):
    return [_table_as_json(table, url, fetch_date) for table, url in tables]
