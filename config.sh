#!/usr/bin/env bash

# What do you have to type into the command line to make these commands execute?
# (If the binary file lives in a directory that is not included in your $PATH
# variable, you will need to include the path here.)
BlastDBcommand='makeblastdb'
BlastXcommand='blastx'

# For including extra blastx options. Don't change anything relating to file 
# input/output (including formatting) and don't change --max_target_seqs.
BlastXargs=''

# To increase specificity, discard blastx hits with an evalue greater than this:
MaxEvalue='0.01'

# The names of temporary files we'll create (usually no need to change these).
TempFile_BlastOut1="temp_1.blast"
TempFile_BlastOut2="temp_2.blast"
TempFile_BlastOut3="temp_3.blast"
