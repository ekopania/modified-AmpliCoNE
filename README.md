# modified-AmpliCoNE
This is a modification to the AmpliCoNE tool: https://github.com/makovalab-psu/AmpliCoNE-tool

Note: I did NOT write AmpliCoNE. I made these modifications so that AmpliCoNE would work better with the mouse genome.

### Install software for generating mappability files:
conda install -c bioconda bedops
conda install -c bioconda ucsc-bedgraphtobigwig
#Install GEM binaries from https://sourceforge.net/projects/gemlibrary/files/gem-library/Binary%20pre-release%203/

### Running scripts
Requires a reference file in fasta format, currently hardcoded as "mm10.fa"
