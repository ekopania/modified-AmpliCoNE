# modified-AmpliCoNE
This is a modification to the AmpliCoNE tool: https://github.com/makovalab-psu/AmpliCoNE-tool  

Note: I did NOT write AmpliCoNE. I made these modifications so that AmpliCoNE would be compatible with the mouse genome.

### Main differences from the original AmpliCoNE
The original AmpliCoNE identifies informative sites, which are the starting sites of k-mers unique to a gene family only occuring once within each paralog of the gene family. It does this by dividing an ampliconic gene into k-mers and mapping these back to the chromosome the gene family is on, identifying k-mers that map exactly the number of times as there are paralogs in the gene family, and then considering the start sites of those k-mer mappings to be informative.

We ran into issues with this approach when applying it to mice, likely because the mouse genome assembly and annotation are not as high quality as the human genome, and mouse gene ampliconic families tend to have much higher copy number compared to primate ampliconic families. Therefore, it is difficult to specify the exact number of paralogs in each mouse ampliconic gene family.

In this modified version of AmpliCoNE, we still map k-mers of ampliconic genes back to the chromosome. Then, we identify the most common number of times mapped (i.e., the mode, 'm'), and keep k-mers that map m times. The start sites of these k-mer mappings are considered informative sites. This method is more robust to mis-specifying the number of paralogs for an ampliconic gene family, which works better for the mouse genome.

### Install software for generating mappability files:
* conda install -c bioconda bedops
* conda install -c bioconda ucsc-bedgraphtobigwig
* Install GEM binaries from https://sourceforge.net/projects/gemlibrary/files/gem-library/Binary%20pre-release%203/

### Running scripts
Requires a reference file in fasta format, currently hardcoded as "mm10.fa"

Reference file must be indexed using bowtie2-index and named with the prefix "bowtie2_index" (ex: bowtie2_index.1.bt2)

Uses RepeatMasker and TandemRepeatFinder files for mm10

Path to modified AmpliCoNE software is currently hardcoded and must be edited at the beginning of these scripts:
* 00_generate_gene_definition.sh
* 02_run_first_build_steps.sh
* 03_count_kmer_mappings.sh
* 05_get_informative_sites.sh
* 07_build_chr_annotation.sh
* 08_run_amplicon.sh

The AmpliCoNE bin/ directory must be in the same directory from which you are running the programs. Recommend using symbolic links:

    ln -s <path_to_modified-AmpliCoNE>/AmpliCoNE_scripts/bin/* <directory_running_AmpliCoNE_from>
