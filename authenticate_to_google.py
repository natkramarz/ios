#!/usr/bin/env python3
import os
import os.path
import pickle

from google.auth.transport.requests import Request
from google_auth_oauthlib.flow import InstalledAppFlow


def authenticate_to_google(scopes):
    print(path_to_this_dir())
    credentials = _load_user_credentials()
    if credentials and credentials.valid:
        return credentials
    else:
        new_credentials = _authenticate(credentials, scopes)
        _save_credentials_for_next_run(new_credentials)
        return new_credentials


def _load_user_credentials():
    dir_path = path_to_this_dir()
    if os.path.exists(os.path.join(dir_path, 'credentials/token.pickle')):
        with open(os.path.join(dir_path, 'credentials/token.pickle'), 'rb') as token:
            return pickle.load(token)
    else:
        return None


def _authenticate(credentials, scopes):
    if credentials and credentials.expired and credentials.refresh_token:
        credentials.refresh(Request())
        return credentials
    else:
        dir_path = path_to_this_dir()
        flow = InstalledAppFlow.from_client_secrets_file(
            os.path.join(dir_path, 'credentials/google-sheets-api-credentials.json'), scopes)
        return flow.run_local_server(port=0)


def _save_credentials_for_next_run(credentials):
    # Save the credentials for the next run
    dir_path = path_to_this_dir()
    with open(os.path.join(dir_path, 'credentials/token.pickle'), 'wb') as token:
        pickle.dump(credentials, token)


def path_to_this_dir():
    return os.path.dirname(__file__)

