#!/usr/bin/env python3
import os
import pathlib
import sys


def replace_in_assets(old: str, new: str) -> None:
    if not old or old == new:
        return
    asset_dir = pathlib.Path("/usr/share/nginx/html/assets")
    if not asset_dir.exists():
        return
    for path in asset_dir.glob("*.js"):
        data = path.read_text(encoding="utf-8")
        updated = data.replace(old, new)
        if updated != data:
            path.write_text(updated, encoding="utf-8")


replace_in_assets(
    os.environ.get("BASE_CMU_CLIENT_ID", ""),
    os.environ.get("CMU_OAUTH_CLIENT_ID", ""),
)
replace_in_assets(
    os.environ.get("BASE_CMU_REDIRECT_URI", ""),
    os.environ.get("CMU_OAUTH_REDIRECT_URI", ""),
)

if len(sys.argv) < 2:
    raise SystemExit("frontend-entrypoint: command is required")
os.execvp(sys.argv[1], sys.argv[1:])
