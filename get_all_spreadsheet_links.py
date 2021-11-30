#!/usr/bin/env python3
import dataclasses
import re
from urllib.parse import unquote
from urllib.parse import urlparse
import requests

from credentials import tokens

GITLAB_TOKEN = tokens.GITLAB_TOKEN


@dataclasses.dataclass
class SpreadSheet:
    url: str
    id: str
    gid: str


def get_all_spreadsheet_links():
    response = requests.get(
        "https://gitlab.ocado.tech/api/v4/projects/21971/repository/files/data-governance%2Fdata-dictionary.md/raw?ref=master",
        headers={"Private-Token": GITLAB_TOKEN})

    lines_of_data_lake_docs = response.text.split("\n")
    lines_with_spreadsheets = filter(
        lambda line: "https://docs.google.com" in line, lines_of_data_lake_docs)
    split_by_pipe = [
        new_line for line in lines_with_spreadsheets for new_line in
        line.split("|")]

    spreadsheets = []
    incomplete = []
    for line in split_by_pipe:
        match = re.search("(https://docs.google.com.*\))", line)
        if not match:
            continue
        uncoded_without_tiling_bracket = unquote(match.group(0)[:-1])
        without_additional_params = uncoded_without_tiling_bracket.split('&sa')[
            0]
        parsed = urlparse(without_additional_params)

        gid = parsed.fragment[4:] if parsed.fragment.startswith(
            "gid=") else None
        sid_match = re.search('\/spreadsheets\/d\/([^\/]+)(\/edit)?',
                              parsed.path)
        sid = sid_match.group(1) if sid_match else None

        spreadsheet = SpreadSheet(url=without_additional_params, id=sid,
                                  gid=gid)
        spreadsheets.append(spreadsheet)
        if not sid or not gid:
            incomplete.append(spreadsheet)

    return spreadsheets, incomplete


if __name__ == "__main__":
    all = get_all_spreadsheet_links()
    print("---- ALL ---")
    for line in all[0]: print(line)
    print("---- INCOMPLETE ---")
    for line in all[1]: print(line)
