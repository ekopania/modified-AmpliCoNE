#!/bin/bash
##PURPOSE: Run the first steps of AmpliCoNE-build to generate GC content files, repeat masker files, and kmer fasta
# Job name:
#SBATCH --job-name=start_build
#SBATCH --output=start_build-%j.log
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=ekopania4@gmail.com # Where to send mail
#SBATCH --cpus-per-task=1 # Number of cores per MPI rank (ie number of threads, I think)
#SBATCH --nodes=1 #Number of nodes
#SBATCH --ntasks=1 # Number of MPI ranks (ie number of processes, I think)
#SBATCH --mem-per-cpu=64G #Not sure if I should mess with these...
#SBATCH --mem=64G #Not sure if I should mess with these...
# Partition:
## Since you want to run it on 72 cores, the partition good_cpu has nodes with 72 cores.
#SBATCH --partition=good_lab_reincarnation
##SBATCH -w, --nodelist=compute-0-8 # run on a specific node
#
## Command(s) to run:
amp_path="/home/ek112884/software/modified-AmpliCoNE/" #Path to modified AmpliCoNE software
chr="5"
ref_fa="mm10.fa"
map_bed="mm10_mappability.bed"
echo "Running early steps of Amplicone-build for chromosome ${chr}..."

#Run Amplicone program for generating annotation
${amp_path}AmpliCoNE_scripts/AmpliCoNE-build.sh -c chr${chr} -i ${ref_fa} -m ${map_bed} -r REFS/RepeatMaskerOutput/chr${chr}.fa.out -t REFS/TandemRepeatFinderOutput/chr${chr}.bed -g gene_definition_mm10.pID97.chr${chr}.tab -o chr${chr}_annotation.tab -s 1 #Start at build step 1

echo "Done!"
