from time import sleep

import gspread

from authenticate_to_google import authenticate_to_google

client = None


def create_client():
    SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']
    credentials = authenticate_to_google(SCOPES)
    return gspread.authorize(credentials)


def get_all_data_from_spreadsheet(id: str, gid: str):
    global client
    if not client:
        client = create_client()

    url = 'https://docs.google.com/spreadsheets/d/' + id
    spreadsheet = client.open_by_url(url)
    try:
        worksheet = spreadsheet.get_worksheet_by_id(
            int(gid)) if gid is not None else spreadsheet.get_worksheet(0)
    except Exception as e:
        print(str(e))
        if (len(spreadsheet.worksheets())) == 1:
            worksheet = spreadsheet.get_worksheet(0)
        else:
            raise Exception(
                "Spreadsheet has more than one sheet inside. Gid is invalid. Cannot determine which to use. Please do it manually")
    return worksheet.get_all_values()


MAX_RETRY_NUMBER = 3


def is_quota_exception(e: Exception):
    try:
        return e.args[0]['status'] == "RESOURCE_EXHAUSTED"
    except:
        return False

def get_all_data_from_spreadsheet_with_retry(id: str, gid: str,
    retry_number: int = 0):
    try:
        sleep(0.5)
        return get_all_data_from_spreadsheet(id, gid)
    except Exception as e:
        print(" Error while getting data" + str(e))
        if retry_number < MAX_RETRY_NUMBER and is_quota_exception(e):
            next_retry_number = (retry_number + 1)
            sleep(61 * next_retry_number)
            return get_all_data_from_spreadsheet_with_retry(id, gid,
                                                            retry_number + 1)
        else:
            raise e
