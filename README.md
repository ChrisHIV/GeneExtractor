# GeneExtractor
GeneExtractor takes one or more nucleotide sequences and translates (part of) each sequence to amino acids by using blastx to match to some known protein sequences.

### Usage
Assuming you've downloaded this code to ~/GeneExtractor; run the one-off initialisation step
```
~/GeneExtractor/genext_init.sh  ~/GeneExtractor/config.sh  MyRefProteins.fasta  MyDataBase
```
where `config.sh` is the configuration file, in which you can customise parameters; `MyRefProteins.fasta` is an ungapped/unaligned fasta file containing the protein sequence of the region you're interested in extracting, preferably taken from many different references to increase the change of finding a good match for the nucleotide sequences you're going to process; and `MyDataBase` is the path where you would like create a blast database from those reference proteins.  
Then, when you want to get the corresponding protein sequence for each a set of nucleotide sequences contained in `MyQuerySeqs.fasta`, run
```
~/GeneExtractor/genext_init.sh  ~/GeneExtractor/config.sh  MyDataBase  MyQuerySeqs.fasta  MyOutput.fasta
```
and the desired output will be in `MyOutput.fasta`.
