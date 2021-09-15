#!/bin/bash
##PURPOSE: Run AmpliCoNE
# Job name:
#SBATCH --job-name=chr14_pID97_amplicone_WDIScombined
#SBATCH --output=amplicone.WDIScombined.OWN_METHOD.chr14.log
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

###TEST RUN - ONE SAMPLE###
#ls /mnt/beegfs/ek112884/cnvs/DATA/MAPPED/PRJEB9450_MAPPED/ERR899393.bam | while read file; do
##	name=$(echo "${file}" | cut -d "/" -f 8 | cut -d "." -f 1)
#	name=$(echo "${file}" | cut -d "/" -f 9 | cut -d "." -f 1)
#       echo "${name}"
#	python ~/software/AmpliCoNE-tool-numMappingVersion/AmpliCoNE-count.py --GENE_DEF gene_definition_mm10.pID${pID}.chr${chr}.tab  --ANNOTATION chr${chr}_annotation.OWN_METHOD.kmerStartOnly.tab --BAM ${file} --CHR ${chr} --LENGTH ${chr_len} --OUTPUT "${name}.chr${chr}.kmerStartOnly.pID${pID}"
#done

###LOOP THROUGH ALL SAMPLES###
#ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/PRJEB9450_PROCESSED/ERR*.marked_duplicates.coordsort.bam | while read file; do
#ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/PRJEB11742_PROCESSED/ERR*.marked_duplicates.coordsort.bam | while read file; do
#ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/PRJEB14167_PROCESSED/AFG?.marked_duplicates.coordsort.bam | while read file; do
#ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/PRJEB15190_PROCESSED/*EiJ.marked_duplicates.coordsort.bam | while read file; do
#ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/WDIS/*.marked_duplicates.coordsort.withTags.bam | while read file; do
ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/WDIS_COMBINED/*.WDISmerged.bam | while read file; do
	name=$(echo "${file}" | cut -d "/" -f 8 | cut -d "." -f 1)
#	name=$(echo "${file}" | cut -d "/" -f 9 | cut -d "." -f 1)
	echo "${name}"
	python ~/software/AmpliCoNE-tool-numMappingVersion/AmpliCoNE-count.py --GENE_DEF gene_definition_mm10.pID${pID}.chr${chr}.tab  --ANNOTATION chr${chr}_annotation.OWN_METHOD.kmerStartOnly.tab --BAM ${file} --CHR ${chr} --LENGTH ${chr_len} --OUTPUT "${name}.chr${chr}.kmerStartOnly.pID${pID}" 

done


###OLD LOOPS###
#ls PROCESSED_BAMS/PRJEB9450/ERR899393.marked_duplicates.coordsort.addChr.bam | while read file; do
#ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/WDIS/*.mark_duplicates.coordsort.downsampleTo5X.bam | while read file; do
#ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/PRJEB11742_PROCESSED/ERR*.mark_duplicates.coordsort.downsampleTo5X.bam | while read file; do
#ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/PRJEB9450_PROCESSED/ERR*.downsampleTo5X.bam | while read file; do
#ls /mnt/beegfs/ek112884/cnvs/PROCESSED_BAMS/WDIS_WGS_PROCESSED/*marked_duplicates.coordsort.bam | while read file; do
#ls /mnt/beegfs/ek112884/cnvs/DATA/MAPPED/WDIS_WGS_MAPPED/B10*Y.bam /mnt/beegfs/ek112884/cnvs/DATA/MAPPED/WDIS_WGS_MAPPED/????.bam /mnt/beegfs/ek112884/cnvs/DATA/MAPPED/WDIS_WGS_MAPPED/PCONR1.bam | while read file; do

echo "Done!"
