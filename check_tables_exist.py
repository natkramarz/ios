import json

from google.api_core.exceptions import NotFound
from google.cloud import bigquery

PROJECT_ID = 'prd-atm-eu-storage'


def read_tables_data():
    with open('./out/all_tables.json', 'r') as all_tables_file:
        return json.load(all_tables_file)


def verify_tables_existence(all_tables):
    client = bigquery.Client()
    for table_name, table_details in all_tables.items():
        try:
            client.get_table(f'{PROJECT_ID}.{table_name}')
            # print(f'{table_name} Exist')
        except NotFound as e:
            print(f'{table_name} - Not Found ({table_details["spreadsheetUrl"]})')
        except Exception as e:
            print(f'{table_name} Exception while resolving the table')
            print(table_details)
            print(e)


if __name__ == "__main__":
    all_tables = read_tables_data()
    verify_tables_existence(all_tables)
