#!/bin/bash
##PURPOSE: Run the first steps of AmpliCoNE-build to generate GC content files, repeat masker files, and kmer fasta
# Job name:
#SBATCH --job-name=chr5_start_build
#SBATCH --output=start_build.OWN_METHOD.chr5.log
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
#echo "Building X chromosome"
#~/software/AmpliCoNE-tool-numMappingVersion/AmpliCoNE-build.sh -c chrX -i ../mm10.fa -m ../mm10_mappability.bed -r ../RepeatMaskerOutput/chrX.fa.out -t ../TandemRepeatFinderOutput/chrX.bed -g gene_definition_mm10.pID95.chrX.tab -o chrX_annotation.tab
#sed 's/\.0//' chrX_annotation.tab > chrX_annotation.temp.tab
#sed 's/\.0$//' chrX_annotation.temp.tab > chrX_annotation.101MER_95PID_OWN_METHOD.tab
#rm chrX_annotation.tab
#rm chrX_annotation.temp.tab

chr="5"
echo "Running early steps of Amplicone-build for chromosome ${chr}..."
#Amplicone program looks for file called "informative_sites.tab"; link this to the informative sites file for the Y chromosome
#rm informative_sites.tab
#ln -s "${chr}_Informative_101bp.tab" informative_sites.tab
#Run Amplicone program for generating annotation
~/software/AmpliCoNE-tool-numMappingVersion/AmpliCoNE-build.sh -c chr${chr} -i ../mm10.fa -m ../mm10_mappability.bed -r ../RepeatMaskerOutput/chr${chr}.fa.out -t ../TandemRepeatFinderOutput/chr${chr}.bed -g gene_definition_mm10.pID97.chr${chr}.tab -o chr${chr}_annotation.tab -s 1 #Start at build step 1
#Change name of Amplicone output file
#sed 's/\.0//' chrY_annotation.tab > chrY_annotation.temp.tab
#sed 's/\.0$//' chrY_annotation.temp.tab > chrY_annotation.101MER_95PID_OWN_METHOD.tab
#sed 's/\.0$//' chrY_annotation.temp.tab > chrY_annotation.101MER_95PID_OWN_METHOD.kmerStartOnly.tab
#rm chrY_annotation.tab
#rm chrY_annotation.temp.tab

echo "Done!"
