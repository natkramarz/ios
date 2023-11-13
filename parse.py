import dataclasses
from typing import List, Dict, Optional, Any


@dataclasses.dataclass(frozen=True)
class Column:
    full_name: str
    description: str
    enumeration: List[str] | None
    data_type: str | None
    nullable: bool | None
    anonymize: bool | None
    example_value: str | None


@dataclasses.dataclass
class Table:
    dataset: Optional[str] = None
    table_name: Optional[str] = None
    description: Optional[str] = None
    classification: Optional[str] = None
    type: Optional[str] = None
    frequency: Optional[str] = None
    version: Optional[str] = None
    columns: Optional[List[Column]] = None
    warnings: Optional[List[str]] = None

    def dataset_and_name(self):
        if not self.dataset or not self.table_name:
            return "UNKNOWN"
        return self.dataset + "." + self.table_name

    def is_valid(self):
        return self.dataset and self.table_name

    def is_complete(self):
        return self.dataset and self.table_name and self.description and len(
            self.columns) > 0

    def has_warnings(self):
        return len(self.warnings) > 0


def _parse_enum_column_value_in_row(
    row: List[str], column_name: str, column_indices: Dict[str, int]):
    field = _parse_column_value_in_row(row, column_name, column_indices)
    if field is None:
        return None
    enumerations_without_new_lines = field.split('\n')
    enumerations_without_commas = []
    for enumeration in enumerations_without_new_lines:
        enumerations_without_commas.extend(enumeration.split(','))

    enumerations_without_quotes = []
    for enumeration in enumerations_without_commas:
        enumeration = enumeration.replace('"', '')
        enumerations_without_quotes.append(enumeration.strip())
    enumerations_without_empty_values = [item.strip() for item
                                         in enumerations_without_quotes
                                         if item != ""]
    if len(enumerations_without_empty_values) == 0:
        return None
    return enumerations_without_empty_values


def _parse_bool_column_value_in_row(
    row: List[str], column_name: str, column_indices: Dict[str, int]):
    field = _parse_column_value_in_row(row, column_name, column_indices)
    if field is None:
        return None
    elif field.lower() in ['y', 'yes', 'on', '1', 'true']:
        return True
    elif field.lower() in ['n', 'no', 'off', '0', 'false']:
        return False
    else:
        return None


def _parse_column_value_in_row(row: List[str], column_name: str, column_indices: Dict[str, int]):
    if column_name not in column_indices:
        return None
    field = row[column_indices[column_name]].strip()
    if field == '-' or field == "":
        return None
    return field


def _extract_to_column(column_indices: Dict[Any, int], column_name: str, row: Any) -> Column:
    column_definition = _parse_column_value_in_row(
        row=row,
        column_name='Definition',
        column_indices=column_indices
    ) or ''
    column_enumeration = _parse_enum_column_value_in_row(
        row=row,
        column_name='Enumeration',
        column_indices=column_indices
    )
    column_data_type = _parse_column_value_in_row(
        row=row, column_name='Data Type',
        column_indices=column_indices
    )
    column_nullable = _parse_bool_column_value_in_row(
        row=row, column_name='Nullable?',
        column_indices=column_indices
    )
    column_anonymize = _parse_bool_column_value_in_row(
        row=row, column_name='Anonymise',
        column_indices=column_indices
    )
    column_example_value = _parse_column_value_in_row(
        row=row, column_name='Example Values',
        column_indices=column_indices
    )
    return Column(full_name=column_name,
                  description=column_definition,
                  enumeration=column_enumeration,
                  data_type=column_data_type,
                  nullable=column_nullable,
                  anonymize=column_anonymize,
                  example_value=column_example_value)


def _extract_table_column_name(column_name: str, ascendant_column_name_list: List[str]):
    current_column_depth = len(column_name) - len(column_name.lstrip("."))

    if current_column_depth:
        stripped_column_name = column_name.lstrip('.')
        ascendant_depth = len(ascendant_column_name_list) - 1

        if current_column_depth <= ascendant_depth:
            ascendant_column_name_list = ascendant_column_name_list[:current_column_depth]

        ascendant_column_name_list.append(stripped_column_name)
        column_name = ".".join(ascendant_column_name_list)
    else:
        ascendant_column_name_list = [column_name]

    return column_name, ascendant_column_name_list


def _extract_to_table(table_def_column_value: Dict[str, str], columns: List[Column], warnings: List[str]) -> Table:
    table = Table()
    table_attributes_accurate = {
        'Object Name': 'table_name',
        'Table Name': 'table_name',
        'Frequency': 'frequency',
        'Object Type': 'type',
        'Object Classification': 'classification',
        'Version': 'version'
    }

    for table_column_name, table_column_value in table_def_column_value.items():
        if table_column_name in table_attributes_accurate:
            setattr(table, table_attributes_accurate[table_column_name], table_column_value.strip())
        elif table_column_name.startswith("Dataset"):
            table.dataset = table_column_value.strip()
        elif table_column_name == "Definition" and table_column_value != '<Give a definition of how the table should be used and why its been created>':
            table.description = table_column_value

    table.columns = columns
    table.warnings = warnings

    return table


def parse(rows) -> Table:
    columns = []
    warnings = []
    columns_started = False
    column_indices = {}
    ascendant_column_name_list = []
    table_def_column_value: Dict[str, str] = {}
    for row in rows:
        if row is None or len(row) == 0:
            continue
        found_columns_header = False
        for column_i in range(0, len(row)):
            if row[column_i] == 'Attribute Name':
                columns_started = True
                found_columns_header = True
                for column_names_index in range(column_i, len(row)):
                    column_indices[row[column_names_index]] = column_names_index
                break
        if found_columns_header:
            continue
        if columns_started:
            table_column_name = _parse_column_value_in_row(
                row=row, column_name='Attribute Name',
                column_indices=column_indices
            )
            if table_column_name:
                table_column_name, ascendant_column_name_list = _extract_table_column_name(table_column_name, ascendant_column_name_list)
                column = _extract_to_column(column_indices=column_indices,
                                            column_name=table_column_name,
                                            row=row)
                column_already_present = any(obj.full_name == table_column_name for obj in columns)

                if not column_already_present:
                    columns.append(column)
                else:
                    warnings.append("SKIPPING COLUMN WITH DUPLICATE COLUM NAME '" + table_column_name + "'")
        else:
            table_def_column_value[row[0]] = row[1]
    return _extract_to_table(table_def_column_value, columns, warnings)


def pretty_print(table: Table):
    print("=== TABLE ===")
    print("name:        " + table.dataset_and_name())
    print("description: " + str(table.description))
    print("columns:")
    for column in table.columns:
        print(str(column.full_name) + " -> " + str(column.description))
    print("\n\n")
