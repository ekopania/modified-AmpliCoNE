#!/bin/bash
##PURPOSE: Generate gene definition files per chromosome for AmpliCoNE
# Job name:
#SBATCH --job-name=customMethod_build_chr_annotation
#SBATCH --output=build_chr_annotation.OWN_METHOD.chr14.log
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=ekopania4@gmail.com # Where to send mail
#SBATCH --cpus-per-task=1 # Number of cores per MPI rank (ie number of threads, I think)
#SBATCH --nodes=1 #Number of nodes
#SBATCH --ntasks=1 # Number of MPI ranks (ie number of processes, I think)
#SBATCH --mem-per-cpu=128G #Not sure if I should mess with these...
#SBATCH --mem=128G #Not sure if I should mess with these...
# Partition:
## Since you want to run it on 72 cores, the partition good_cpu has nodes with 72 cores.
#SBATCH --partition=good_lab_reincarnation
##SBATCH -w, --nodelist=compute-0-8 # run on a specific node
#
## Command(s) to run:
chr="14"
echo "Building ${chr} chromosome annotation..."
#Amplicone program looks for file called "informative_sites.tab"; link this to the informative sites file for the chromosome you are working on
rm informative_sites.tab
ln -s "${chr}_Informative_101bp.tab" informative_sites.tab
#Run Amplicone program for generating annotation
~/software/AmpliCoNE-tool-numMappingVersion/AmpliCoNE-build.sh -c chr${chr} -i ../mm10.fa -m ../mm10_mappability.bed -r ../RepeatMaskerOutput/chr${chr}.fa.out -t ../TandemRepeatFinderOutput/chr${chr}.bed -g gene_definition_mm10.pID97.chr${chr}.tab -o chr${chr}_annotation.tab -s 7 #Start Amplicone-build.sh from step 7, building the annotation
#Change name of Amplicone output file
sed 's/\.0//' chr${chr}_annotation.tab > chr${chr}_annotation.temp.tab
sed 's/\.0$//' chr${chr}_annotation.temp.tab > chr${chr}_annotation.OWN_METHOD.kmerStartOnly.tab
rm chr${chr}_annotation.tab
rm chr${chr}_annotation.temp.tab

echo "Done!"
