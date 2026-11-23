#!/bin/sh
_REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
_ROMHACKS="$(dirname "$_REPO_ROOT")"
# Build the SameBoy bridge for the regression harness.
set -e
SB=${SAMEBOY:-$_ROMHACKS/SameBoy}
cd "$(dirname "$0")"
gcc -O2 -fPIC -shared -I"$SB/Core" sbshim.c -L"$SB/build/lib" -lsameboy -Wl,-rpath,"$SB/build/lib" -lm -o libsbshim.so
echo built libsbshim.so
