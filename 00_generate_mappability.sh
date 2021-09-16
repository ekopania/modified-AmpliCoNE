#!/bin/bash
##PURPOSE: Run gem-mappability pipeline to generate mappability files for AmpliCoNE
# Job name:
#SBATCH --job-name=gem_mappability
#SBATCH --output=gem_mappability-%j.log
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=ekopania4@gmail.com # Where to send mail
#SBATCH --cpus-per-task=1 # Number of cores per MPI rank (ie number of threads, I think)
#SBATCH --nodes=1 #Number of nodes
#SBATCH --ntasks=1 # Number of MPI ranks (ie number of processes, I think)
#SBATCH --mem-per-cpu=96G #Not sure if I should mess with these...
#SBATCH --mem=192000 #Not sure if I should mess with these...
# Partition:
## Since you want to run it on 72 cores, the partition good_cpu has nodes with 72 cores.
#SBATCH --partition=good_lab_cpu
##SBATCH -w, --nodelist=compute-0-4 # run on a specific node
#
## Command(s) to run:
ref_fa="mm10.fa"
ref_name=$(echo "${ref_fa}" | cut -d "." -f 1)

gem-indexer -i ${ref_fa} -o ${ref_fa} --complement emulate --verbose
gem-mappability -I ${ref_fa}.gem -l 101 -o ${ref_name}.mappability_output -m 2 -e 2
gem-2-wig -I ${ref_fa}.gem -i ${ref_name}.mappability_output.mappability -o ${ref_name}.mappability_wig
wig2bed -b ${ref_name} < ${ref_name}.mappability_wig.wig > ${ref_name}_mappability.bed

echo "Done!"
