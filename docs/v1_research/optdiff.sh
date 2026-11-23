#!/bin/sh
_REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
_ROMHACKS="$(dirname "$_REPO_ROOT")"
# Compare optimize.py output ignoring line numbers.
cd "$_REPO_ROOT"
python3 utils/optimize.py 2>/dev/null > .opt.new
diff <(sed -E 's/line=[0-9]+/line=N/' .opt.old | sort) <(sed -E 's/line=[0-9]+/line=N/' .opt.new | sort) && echo OPT-OK
