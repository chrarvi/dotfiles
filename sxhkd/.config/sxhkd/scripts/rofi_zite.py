#!/usr/bin/env python3
"""Use Rofi to search and open Zite pdfs.

Requirements:
- Python 3.7 or newer
- Rofi

"""

import os
import argparse
import sys
import json
import subprocess
import shlex
from typing import Any, Dict
import datetime

HOME = os.environ["HOME"]

ZITE_DIR = os.path.join(HOME, "zite")
ZITE_INDEX = os.path.join(ZITE_DIR, "index.json")

DEFAULT_VIEWER = "xdg-open %u"

def parse_args():
    parser = argparse.ArgumentParser(description="rofi-zite")

    parser.add_argument(
        "--viewer", type=str, default=DEFAULT_VIEWER, help=(
            "Application to open pdfs with, including '%%u' to indicate path arg. "
            f"Defaults to {DEFAULT_VIEWER.replace("%", "%%")}"
        )
    )
    return parser.parse_args()

def open_file(app, file_path, only_return_command=False):
    """Attempt to open ``file_path`` using ``app``.

    Parameters
    ----------
    app : str
        Application to open file. Should contain '%u' for where the file path
        would appear in the command. If '%u' is not provided, it is assumed
        that the file path is the last argument to the command.
    file_path : str
        Path to file to open.
    only_return_command : bool
        If True, only return the command and do not execute it. Default: False.

    Returns
    -------
    list
        Command that was run.

    """
    app_and_args = shlex.split(app)
    if "%u" not in app_and_args:
        app_and_args.append("%u")

    command = [arg if arg != "%u" else file_path for arg in app_and_args]

    if not only_return_command:
        subprocess.run(command)

    return [str(cmd_part) for cmd_part in command]


def show_error(error_msg, rofi_args=None):
    """Show ``error_msg`` as an error message in Rofi and stderr."""
    if rofi_args is None:
        rofi_args = []
    print(error_msg, file=sys.stderr)
    subprocess.run(["rofi", "-e", error_msg] + rofi_args)


def format_entry(entry: Dict[str, Any]) -> str:
    title = entry["title"]
    year = datetime.datetime.fromisoformat(entry["published_date"]).year
    authors = ", ".join(entry["authors"])
    return f"""\
<b>{title}</b>
<span foreground=\"lightgreen\">({year})</span> <span foreground=\"gray\"><i>{authors}</i></span>
    """

def main():
    args = parse_args()

    with open(ZITE_INDEX, "r") as f:
        index = json.load(f)

    item_list = [format_entry(item) for item in index.values()]
    items_input = "|".join(item_list)

    rofi_command = ["rofi", "-markup-rows", "-dmenu", "-i", "-format", "i", "-sep", '|', "-eh", "2", "-p", "Open Zite PDF"]
    rofi = subprocess.run(
        rofi_command, capture_output=True, text=True, input=items_input
    )
    selected_index = rofi.stdout.strip()

    metadata_path = os.path.join(ZITE_DIR, list(index.values())[int(selected_index)]["metadata_path"])
    with open(metadata_path, "r") as f:
        metadata = json.load(f)
    pdf_path = os.path.join(ZITE_DIR, metadata["pdf"])

    if os.path.isfile(pdf_path):
        try:
            open_file(args.viewer, pdf_path)
        except FileNotFoundError:
            viewer_command = open_file(args.viewer, pdf_path, only_return_command=True)
            viewer_command = [str(cmd_part) for cmd_part in viewer_command]
            viewer_command = " ".join(viewer_command)
            show_error(
                f"Could not run command: '{viewer_command}'\n"
                f"Make sure the viewer is installed"
            )


if __name__ == "__main__":
    main()
