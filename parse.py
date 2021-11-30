import dataclasses
from typing import List


@dataclasses.dataclass
class Column:
    full_name: str
    description: str


@dataclasses.dataclass
class Table:
    dataset: str
    table_name: str
    description: str
    columns: List[Column]

    def datasetAndName(self):
        if not self.dataset or not self.table_name:
            return "UNKNOWN"
        return self.dataset + "." + self.table_name

    def is_valid(self):
        return self.dataset and self.table_name

    def is_complete(self):
        return self.dataset and self.table_name and self.description and len(
            self.columns) > 0


def parse(rows) -> Table:
    object_name = None
    dataset = None
    definition = ''
    column = []
    columns_started = False
    column_definition_number = 1
    last_full_column_name = ""
    for row in rows:
        if len(row) == 0:
            continue
        key = row[0]
        if key == "Table Name":
            column_definition_number = 4
        if columns_started:
            column_name = row[column_definition_number - 1].strip()
            if len(column_name) > 0:
                if column_name.startswith("."):
                    # lstrip usedfor cases with multiple dots at the begining
                    column_name = last_full_column_name + "." + column_name.lstrip(
                        '.')
                else:
                    last_full_column_name = column_name
                column_definition = row[column_definition_number]
                column.append(
                    Column(full_name=column_name,
                           description=column_definition))
                continue
        if key == "Attribute Name" or key == "Dataset/Bucket":
            columns_started = True
            continue
        if key == "Object Name" or key == "Table Name":
            object_name = row[1].strip()
        if key.startswith("Dataset"):
            dataset = row[1].strip()
        if key == "Definition":
            definition = row[1]
        if key == "Definition":
            definition = row[1]
    return Table(dataset=dataset, table_name=object_name,
                 description=definition,
                 columns=column)


def pretty_print(table: Table):
    print("=== TABLE ===")
    print("name:        " + table.datasetAndName())
    print("description: " + str(table.description))
    print("columns:")
    for column in table.columns:
        print(str(column.full_name) + " -> " + str(column.description))
    print("\n\n")
