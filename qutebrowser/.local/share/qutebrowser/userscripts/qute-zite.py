#!/usr/bin/env python3

import os
import subprocess

FIFO = open(os.environ["QUTE_FIFO"], "w")


def notify(message):
    print('message-info "{}"'.format(message), file=FIFO, flush=True)


def notify_error(message):
    print('message-error "{}"'.format(message), file=FIFO, flush=True)


def main():
    url = os.environ["QUTE_URL"]
    notify(f"[zite] Fetching {url} and PDF...")

    cmd = ["zite", "fetch", url]
    result = subprocess.run(cmd)
    if result.returncode == 1:
        notify_error(f"[zite] Failed to fetch: {result.stderr}")
    else:
        notify(f"[zite] Fetched {url} and PDF")


if __name__ == "__main__":
    main()
