#!/bin/bash
##PURPOSE: Generate gene definition files per chromosome for AmpliCoNE
# Job name:
#SBATCH --job-name=customMethod_build_chr_annotation
#SBATCH --output=build_chr_annotation-%j.log
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=ekopania4@gmail.com # Where to send mail
#SBATCH --cpus-per-task=1 # Number of cores per MPI rank (ie number of threads, I think)
#SBATCH --nodes=1 #Number of nodes
#SBATCH --ntasks=1 # Number of MPI ranks (ie number of processes, I think)
#SBATCH --mem-per-cpu=128G #Not sure if I should mess with these...
#SBATCH --mem=128G #Not sure if I should mess with these...
# Partition:
## Since you want to run it on 72 cores, the partition good_cpu has nodes with 72 cores.
#SBATCH --partition=good_lab_cpu
##SBATCH -w, --nodelist=compute-0-8 # run on a specific node
#
## Command(s) to run:
amp_path="/home/ek112884/software/modified-AmpliCoNE/" #Path to modified AmpliCoNE software
chr="X"
pID=97
echo "Building ${chr} chromosome annotation for paralogs with percent sequence ID >= ${pID}..."
ref_fa="mm10.fa" #Name of reference fasta file
map_bed="mm10_mappability.bed" #Name of mappability bed file

#Amplicone program looks for file called "informative_sites.tab"; link this to the informative sites file for the chromosome you are working on
rm informative_sites.tab
ln -s "${chr}_Informative_101bp.tab" informative_sites.tab
#Run Amplicone program for generating annotation
${amp_path}AmpliCoNE_scripts/AmpliCoNE-build.sh -c chr${chr} -i ${ref_fa} -m ${map_bed} -r REFS/RepeatMaskerOutput/chr${chr}.fa.out -t REFS/TandemRepeatFinderOutput/chr${chr}.bed -g gene_definition_mm10.pID${pID}.chr${chr}.tab -o chr${chr}_annotation.pID${pID}.tab -s 7 #Start Amplicone-build.sh from step 7, building the annotation

#Change name of Amplicone output file
sed 's/\.0//' chr${chr}_annotation.pID${pID}.tab > chr${chr}_annotation.pID${pID}.temp.tab
sed 's/\.0$//' chr${chr}_annotation.pID${pID}.temp.tab > chr${chr}_annotation.pID${pID}.OWN_METHOD.kmerStartOnly.tab
rm chr${chr}_annotation.pID${pID}.tab
rm chr${chr}_annotation.pID${pID}.temp.tab

echo "Done!"
