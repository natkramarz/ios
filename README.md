# data-dictionary-dump

This script extract descriptions from all data dictionary spreadsheets.

## How to run 

### Prerequisites

1. Create `credentials` folder in root of the project
2. Create your gitlab token (it is required to obtain the Data Lake documentation to get all spreadsheets) - [Personal access tokens page](https://gitlab.ocado.tech/-/profile/personal_access_tokens)
   1. Create file `credentials/tokens.py`
   2. Paste inside a line:
    ```python
    GITLAB_TOKEN="YOUR_TOKEN_FROM_GITLAB"
    ```
3. Download json file with credentials to access spreadsheets API
   1. Go [here](https://console.cloud.google.com/apis/credentials?project=dev-atm-osp-datadiscovery-test)
   2. Click arrow button ("Download OAuth client") for `data dictionary dump`
   3. Download json, save this as `credentials/google-sheets-api-credentials.json`

### Run Data Dictionary extract
```bash
mkdir -p out
pipenv install
pipenv run ./app.py
```

### Check existence of tables from Data Dictionary

Dedicated script `check_tables_exist.py` can be used to check if tables defined in data dictionary exists in project configured within the script. Script operates on the output of data dictionary extract and use user credentials to verify table existence.
