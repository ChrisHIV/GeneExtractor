#!/usr/bin/env bash

set -u
set -o pipefail

UsageInstructions=$(echo '
Arguments for this script:
(1) the configuration file, containing your parameter choices etc.;
(2) the same path that for the blast database that you gave as an argument when
you ran genext_init.sh (blast should have created some files whose names have
extensions added to that path, but we need the path without those extensions,
otherwise you will get an unclear error message);
(3) a fasta file of nucleotide sequences from which you want to extract and
translate a particular region;
(4) the path of the output file, where we will put the extracted & translated
sequences.
')

# Check for the right number of arguments. Assign them to variables.
NumArgsExpected=4
if [ "$#" -ne "$NumArgsExpected" ]; then
  echo $UsageInstructions
  echo "$# arguments specified; $NumArgsExpected expected. Quitting." >&2
  exit 1
fi
ConfigFile="$1"
DataBaseStem="$2"
SeqsForExtraction="$3"
OutFile="$4"

# Source the required functions.
ThisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
funcs="$ThisDir/tools/genext_funcs.sh"
source "$funcs" || { echo "Problem sourcing $funcs. Quitting." >&2 ; exit 1; }

CheckFilesExist "$ConfigFile"
source "$ConfigFile" ||
{ echo "Problem sourcing $ConfigFile. Quitting." >&2 ; exit 1; }

CheckFilesDontExist "$OutFile" "$TempFile_BlastOut1"

CheckFasta "$SeqsForExtraction" ||
{ echo "Problem with $SeqsForExtraction. Quitting." >&2 ; exit 1; }

# What info shall we get blast to report? Isolated here for convenience of
# possible future changes.
BlastFields='qseqid qseq evalue sseqid pident qlen qstart qend sstart send'
field_qseqid=1
field_qseq=2
field_evalue=3
NumFields=$(echo $BlastFields | wc -w)

# Blast!
"$BlastXcommand" -query "$SeqsForExtraction" -db "$DataBaseStem" -outfmt \
"10 $BlastFields" -max_target_seqs 1 $BlastXargs >> "$TempFile_BlastOut1" ||
{ echo "Problem blasting $SeqsForExtraction against $DataBaseStem."\
"Quitting." >&2 ; exit 1; }

# Check there was at least one hit.
NumHits=$(wc -l "$TempFile_BlastOut1" | awk '{print $1}')
if [[ $NumHits -eq 1 ]]; then
  echo "There were no hits when blasting $SeqsForExtraction against"\
  "$DataBaseStem. Quitting." >&2
  exit 1
fi

# Impose the evalue threshold. Check at least one hit survives.
echo "$BlastFields" | tr ' ' ',' > "$TempFile_BlastOut2"
awk -F, '{if ($'$field_evalue' <= '$MaxEvalue') print}' "$TempFile_BlastOut1" \
>> "$TempFile_BlastOut2"
NumHitsPlus1=$(wc -l "$TempFile_BlastOut2" | awk '{print $1}')
if [[ $NumHitsPlus1 -eq 0 ]]; then
  echo "No hits survived the requirement that evalue <= $MaxEvalue."\
  "Quitting." >&2
  exit 1
fi

# For seqs with multiple blast hits, keep only the one with the smallest evalue.
"$Code_KeepBestLinesInDataFile" --num_fields $NumFields \
--id_field $field_qseqid --sort_field $field_evalue --header \
"$TempFile_BlastOut2" "$TempFile_BlastOut3" || { echo "Problem running"\
" $Code_KeepBestLinesInDataFile. Quitting." >&2 ; exit 1; }

# Create a fasta output file of the translated sequences from the hits.
awk -F, '{if (NR!=1) {print ">" $'$field_qseqid'; gsub("-", "", $'$field_qseq');
print $'$field_qseq'}}' "$TempFile_BlastOut3" > "$OutFile"
