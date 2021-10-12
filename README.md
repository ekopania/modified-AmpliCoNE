# modified-AmpliCoNE
This is a modification to the AmpliCoNE tool: https://github.com/makovalab-psu/AmpliCoNE-tool

Note: I did NOT write AmpliCoNE. I made these modifications so that AmpliCoNE would work better with the mouse genome.

### Install software for generating mappability files:
conda install -c bioconda bedops
conda install -c bioconda ucsc-bedgraphtobigwig
#Install GEM binaries from https://sourceforge.net/projects/gemlibrary/files/gem-library/Binary%20pre-release%203/

### Running scripts
Requires a reference file in fasta format, currently hardcoded as "mm10.fa"

Path to modified AmpliCoNE software is currently hardcoded and must be edited at the beginning of these scripts: 00_generate_gene_definition.sh, 02_run_first_build_steps.sh, 03_count_kmer_mappings.sh, 05_get_informative_sites.sh, 07_build_chr_annotation.sh, 08_run_amplicon.sh

The AmpliCoNE bin/ directory must be in the same directory from which you are running the programs. Recommend using symbolic links:

'''
ln -s <path_to_modified-AmpliCoNE>/AmpliCoNE_scripts/bin/* <directory_running_AmpliCoNE_from>
'''
