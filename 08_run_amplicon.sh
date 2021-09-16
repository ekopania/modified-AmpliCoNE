#!/bin/bash
##PURPOSE: Run AmpliCoNE
# Job name:
#SBATCH --job-name=run_amplicone
#SBATCH --output=run_amplicone-%j.log
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=ekopania4@gmail.com # Where to send mail
#SBATCH --cpus-per-task=1 # Number of cores per MPI rank (ie number of threads, I think)
#SBATCH --nodes=1 #Number of nodes
#SBATCH --ntasks=1 # Number of MPI ranks (ie number of processes, I think)
#SBATCH --mem-per-cpu=96G #Not sure if I should mess with these...
#SBATCH --mem=96G #Not sure if I should mess with these...
# Partition:
## Since you want to run it on 72 cores, the partition good_cpu has nodes with 72 cores.
#SBATCH --partition=good_lab_reincarnation
##SBATCH -w, --nodelist=compute-0-4 # run on a specific node
#
## Command(s) to run:
chr="14"
chr_len=$(cat "chr${chr}_length.txt")
pID=97
echo "Running amplicone for chromosome ${chr} of length ${chr_len} and percent ID ${pID}"

my_bams=$(ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/WDIS_COMBINED/*.WDISmerged.bam)

for file in ${my_bams[@]}; do
	name=$(echo "${file}" | cut -d "/" -f 8 | cut -d "." -f 1)
#	name=$(echo "${file}" | cut -d "/" -f 9 | cut -d "." -f 1)
	echo "Working on sample: ${name}"
	python AmpliCoNE_scripts/AmpliCoNE-count.py --GENE_DEF gene_definition_mm10.pID${pID}.chr${chr}.tab  --ANNOTATION chr${chr}_annotation.OWN_METHOD.kmerStartOnly.tab --BAM ${file} --CHR ${chr} --LENGTH ${chr_len} --OUTPUT "${name}.chr${chr}.kmerStartOnly.pID${pID}" 
done

echo "Done!"
