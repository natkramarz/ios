from http import HTTPStatus

import gspread
from gspread import BackoffClient

from authenticate_to_google import authenticate_to_google

client = None


class CustomBackoffClient(BackoffClient):
    """CustomBackoffClient extends BackoffClient with custom settings."""
    _HTTP_ERROR_CODES = BackoffClient._HTTP_ERROR_CODES + [HTTPStatus.SERVICE_UNAVAILABLE,
                                                           HTTPStatus.INTERNAL_SERVER_ERROR]
    _MAX_BACKOFF = 600000  # Custom maximum backoff setting

    def __init__(self, auth):
        super().__init__(auth)


def create_client():
    SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']
    credentials = authenticate_to_google(SCOPES)
    return gspread.authorize(credentials, client_factory=CustomBackoffClient)


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
