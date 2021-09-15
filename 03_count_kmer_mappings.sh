#!/bin/bash
##PURPOSE: Loop through Bowtie mapping output and count number of times each kmer mapped
# Job name:
#SBATCH --job-name=chr14_count_kmer_mappings
#SBATCH --output=count_kmer_mappings.chr14.log
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=ekopania4@gmail.com # Where to send mail
#SBATCH --cpus-per-task=1 # Number of cores per MPI rank (ie number of threads, I think)
#SBATCH --nodes=1 #Number of nodes
#SBATCH --ntasks=32 # Number of MPI ranks (ie number of processes, I think)
#SBATCH --mem-per-cpu=32G #Not sure if I should mess with these...
#SBATCH --mem=0 #Not sure if I should mess with these...
# Partition:
## Since you want to run it on 72 cores, the partition good_cpu has nodes with 72 cores.
#SBATCH --partition=good_lab_reincarnation
##SBATCH -w, --nodelist=compute-0-4 # run on a specific node
#
## Command(s) to run:
chr="14"
#Loop through each ampliconic gene
cat ampliconic_genes.chr${chr}.bed | while read line; do #All ${chr} amplicons
#cat ampliconic_genes.chrY.bed | while read line; do #All Y amplicons
#cat ampliconic_genes.chrY.slyOnly.bed | while read line; do #Just sly, for testing
	#echo "${line}"
	gene=$(echo "${line}" | cut -f 6)
	echo "${gene}"
	begin=$(echo "${line}" | cut -f 2)
	end=$(echo "${line}" | cut -f 3)
	last_kmer=$(( ${end} - 101))
	echo "Getting kmers from ${begin} to ${last_kmer}"
	gene_range=$(seq ${begin} ${last_kmer})
	#echo "${gene_range}"
	#Get all kmers that start and end in range of ampliconic gene
	rm "${gene}.kmer_names.txt"
	for i in ${gene_range}; do
		#echo "${i}"
		echo "chr${chr}_${i}" >> "${gene}.kmer_names.txt"
	done
	#Get kmers from within the ampliconic gene
	last_line=$(( ${last_kmer} * 2 ))
	dif=$(( ${last_kmer} - ${begin} + 1))
	first_line=$(( ${dif} * 2 ))
	head -${last_line} "chr${chr}_Sliding_window101bp_Reference_reads.fasta" | tail -${first_line} > "${gene}_kmers.fa"
	#Map just the kmers from ampliconic families, allowing up to 500 multiple mapping hits
	#This should be a lot faster than mapping every kmer from the chromosome
	echo "Mapping ${gene} kmers with Bowtie 2 (-k 500)"
	bowtie2 -k 500 --threads 5 -x bowtie2_index -f "${gene}_kmers.fa" -S "${gene}_101bp_bowtie2_k500.sam"
	#Loop through all kmers; count number of times each maps
	echo "Counting the number of times each kmer maps"
	rm "${gene}.kmer_mapping_counts.txt"
	python parallel_cmd_generator.kmer_counts.py "${gene}" > parallel_cmds.kmer_counts.sh
	parallel -j 32 < parallel_cmds.kmer_counts.sh

	#Plot histogram of kmer mapping counts
	Rscript 04_plot_kmer_mappings.r "${gene}.kmer_mapping_counts.txt"
done

echo "Done!"
