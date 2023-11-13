#!/usr/bin/env python3

import json
from datetime import date
from typing import List

from formatter import format_as_json
from get_all_data_from_spreadsheet import get_all_data_from_spreadsheet
from get_all_spreadsheet_links import SpreadSheet, get_all_spreadsheet_links
from parse import parse, pretty_print


def process(all_spreadsheets: List[SpreadSheet], valid_tables=[], incomplete=[], invalid=[], failed=[], warnings=[]):
    counter = 0
    all_elements = len(all_spreadsheets)
    for spreadsheet in all_spreadsheets:
        counter += 1
        try:
            print(f"""[{counter}/{all_elements}] Downloading all data for spreadsheet -> {spreadsheet.url}""")
            data = get_all_data_from_spreadsheet(spreadsheet.id, spreadsheet.gid)
            table_info = parse(data)

            if table_info.has_warnings():
                warnings.append((spreadsheet.url, table_info.warnings))

            if table_info.is_valid() and table_info.dataset_and_name() != '<Dataset Name>.<Table/View Name>':
                valid_tables.append((table_info, spreadsheet.url))
            else:
                invalid.append((table_info, spreadsheet.url))
                print("[INVALID]")
            if table_info.is_complete():
                print("[OK]")
            else:
                incomplete.append((table_info, spreadsheet.url))
                print("[INCOMPLETE]")
        except Exception as e:
            print("[FAILED]")
            print(str(e))
            failed.append((spreadsheet.url, str(e)))
    return valid_tables, incomplete, invalid, failed, warnings


def download_and_append():
    to_redownload = [
        SpreadSheet(url="", id="1InT5CRO5KpC6C2Hb9kD7-OcvFcW-sh9hubnj3XECxww",
                    gid="1516058266")
    ]
    return process(to_redownload)


if __name__ == '__main__':
    fetch_date = date.today()
    all_spreadsheets, incomplete_links = get_all_spreadsheet_links()
    valid_tables, incomplete, invalid, failed, warnings = process(all_spreadsheets)

    # valid_tables, incomplete, invalid, failed, warnings = download_and_append()

    json_str = format_as_json(valid_tables, fetch_date)
    with open("out/all_tables.json", "w") as out:
        json.dump(json_str, out, indent=2)

    print("############################")
    print("Please check below information")
    print("All the complete elements are saved into out/all_tables.json")

    print("############################")
    print("####### INCOMPLETE #######")
    for table in incomplete:
        print(table[1])
        pretty_print(table[0])

    print("\n\n####### INVALID (have no dataset name or table name) #######")
    for table in invalid:
        print(table[1])
        pretty_print(table[0])

    print("\n\n####### FAILED #######")
    for fail in failed:
        print(fail)

    print("\n\n####### WARNINGS #######")
    for entry in warnings:
        print(entry[0])
        for warning_message in entry[1]:
            print(warning_message)
