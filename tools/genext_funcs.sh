#!/usr/bin/env bash

set -u
set -o pipefail

ThisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
Code_KeepBestLinesInDataFile="$ThisDir/KeepBestLinesInDataFile.py"

# For quitting if files do or don't exist.
function CheckFilesExist {
  for argument in "$@"; do
    if [ ! -f "$argument" ]; then
      echo "$argument" 'does not exist or is not a regular file. Quitting.' >&2
      exit 1
    fi
  done
}
function CheckFilesDontExist {
  for argument in "$@"; do
    if [ -f "$argument" ]; then
      echo "File $argument exists already. Quitting to prevent overwriting." >&2
      exit 1
    fi
  done
}

function CheckFasta {
  InFile=$1
  SeqNames=$(awk '/^>/ {print substr($1,2)}' "$InFile")
  NumRefs=$(echo "$SeqNames" | wc -w)
  if [[ $NumRefs -eq 0 ]]; then
    echo "$InFile contains no sequences (or it is not in fasta format)." >&2
    return 1
  fi
  if [[ "$SeqNames" == *","* ]]; then
    echo "Sequence names must not contain commas." >&2
    return 1
  fi
}
