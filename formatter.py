from typing import List

from parse import Table, Column


def __column_as_json(field: Column):
    return {
        "description": field.description if field.description else ""
    }


def __table_as_json(table: Table):
    return {
        "description": table.description if table.description else "",
        "fields": {column.full_name: __column_as_json(column) for column in
                   table.columns}
    }


def format_as_json(tables: List[Table]):
    return {table.datasetAndName(): __table_as_json(table) for table in tables}
