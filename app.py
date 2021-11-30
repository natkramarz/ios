#!/usr/bin/env python3

import json
from typing import List

from formatter import format_as_json
from get_all_data_from_spreadsheet import \
    get_all_data_from_spreadsheet_with_retry
from get_all_spreadsheet_links import get_all_spreadsheet_links, SpreadSheet
from parse import parse, pretty_print


def process(all_spreadsheets: List[SpreadSheet], valid_tables=[], incomplete=[],
    invalid=[], failed=[]):
    for spreadsheet in all_spreadsheets:
        try:
            print("Downloading all data for spreadsheet -> " + spreadsheet.url)
            data = get_all_data_from_spreadsheet_with_retry(spreadsheet.id,
                                                            spreadsheet.gid)
            table_info = parse(data)

            if table_info.is_valid():
                valid_tables.append(table_info)
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

    return valid_tables, incomplete, invalid, failed


def download_and_append(valid_tables, incomplete, invalid, failed):
    to_redownload = [
        SpreadSheet(url="", id="1teC_-moGab9rrDwYWYpuK31diBgpUGiY4ZaA8F3kcHw",
                    gid="1885066752")
    ]
    process(to_redownload, valid_tables, incomplete, invalid, failed)


if __name__ == '__main__':
    all_spreadsheets, incomplete_links = get_all_spreadsheet_links()
    valid_tables, incomplete, invalid, failed = process(all_spreadsheets)

    download_and_append(valid_tables, incomplete, invalid, failed)

    json_str = format_as_json(valid_tables)
    with open("out/all_tables.json", "w") as out:
        json.dump(json_str, out)

    print("############################")
    print("Please check below information")
    print("All incomplete elements are saved into out/all_tables.json")

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

    print("\n\n####### INVALID LINKS (without id or gid) #######")
