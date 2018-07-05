#!/usr/bin/env bash

set -u
set -o pipefail

UsageInstructions=$(echo '
Arguments for this script:
(1) the configuration file, containing your parameter choices etc.;
(2) a fasta file of ungapped (unaligned) reference amino acid sequences in the
desired region;
(3) the path (minus any file extension) for where we will create a blast
database from those reference sequences.
')

# Check for the right number of arguments. Assign them to variables.
NumArgsExpected=3
if [ "$#" -ne "$NumArgsExpected" ]; then
  echo $UsageInstructions
  echo "$# arguments specified; $NumArgsExpected expected. Quitting." >&2
  exit 1
fi
ConfigFile="$1"
RefGenes="$2"
DataBaseStem="$3"

# Source the required functions.
ThisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
funcs="$ThisDir/tools/genext_funcs.sh"
source "$funcs" || { echo "Problem sourcing $funcs. Quitting." >&2 ; exit 1; }

CheckFilesExist "$ConfigFile" "$RefGenes"
source "$ConfigFile" ||
{ echo "Problem sourcing $ConfigFile. Quitting." >&2 ; exit 1; }

CheckFasta "$RefGenes" ||
{ echo "Problem with $RefGenes. Quitting." >&2 ; exit 1; }

# Check that OutDir does not have whitespace in it
if [[ "$DataBaseStem" =~ ( |\') ]]; then
  echo "Your specified database path $DataBaseStem contains whitespace;"\
  "unfortunately, blast cannot handle whitespace in paths (stupid, I know)."\
  "Try again with a different path. Quitting." >&2
  exit 1;
fi

# Create the blast database
"$BlastDBcommand" -dbtype prot -in "$RefGenes" -input_type fasta -out \
"$DataBaseStem" || { echo "Problem creating a blast database out of $RefGenes."\
" Quitting." >&2 ; exit 1; }
