# data-dictionary-dump

This script extract descriptions from all data dictionary spreadsheets.

## How to run

### Prerequisites

1. Install Python ≥ 3.10 and pipenv
2. Create `credentials` folder in root of the project
3. Create your gitlab token (it is required to obtain the Data Lake documentation to get all spreadsheets) - [Personal access tokens page](https://gitlab.ocado.tech/-/profile/personal_access_tokens)
    1. Create a file `credentials/tokens.py`
    2. Paste the following line inside:
    ```python
   GITLAB_TOKEN="YOUR_TOKEN_FROM_GITLAB"
    ```
4. Download json file with credentials to access spreadsheets API
    1. Go to [Taco](https://euw1-taco.devtools.osp.tech/new-access-request/gcp-projects)
        1. Request for a permission: `CLIENT_AUTH_CONFIG_EDITOR` for the project: `dev-atm-osp-datadiscovery-test`.
        2. After you verify in [Access requests](https://euw1-taco.devtools.osp.tech/history) tab that your request is approved, click `GRANT ACCESS` button - the badge should change to `Access granted` and you will be able to complete the next step.
    2. Go to [GCP API Credentials page](https://console.cloud.google.com/apis/credentials?project=dev-atm-osp-datadiscovery-test)
        1. Click the download button ('Download OAuth client') for `data dictionary dump` entry in `OAuth 2.0 Client IDs` section
        2. Click `DOWNLOAD JSON` and save the file under path `credentials/google-sheets-api-credentials.json`

### Run Data Dictionary extract

You can run the data-dictionary-dump script either from the terminal or via IntelliJ configs

#### Version A - terminal

```bash
mkdir -p out
pipenv install
pipenv run ./app.py
```

#### Version B - IntelliJ

* Open module settings and add & set new Python SDK (≥ 3.10) using option `Pipenv Environment` (remember to check option `Install dependencies from Pipfile`)
* Save the settings and follow the tips IntelliJ displays via banners on top of the screen to install dependencies and setup pipenv
* You can now run/debug the app by pressing Play button by the main function in `app.py`

### Check existence of tables from Data Dictionary

Dedicated script `check_tables_exist.py` can be used to check if tables defined in data dictionary exists in project configured within the script. Script operates on the output of data dictionary extract and use user credentials to verify table existence.
