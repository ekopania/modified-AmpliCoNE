#!/bin/bash
##PURPOSE: Use # times each kmer in gene maps to identify informative sites in mouse genome
# Job name:
#SBATCH --job-name=get_info_sites
#SBATCH --output=get_info_sites-%j.log
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=ekopania4@gmail.com # Where to send mail
#SBATCH --cpus-per-task=8 # Number of cores per MPI rank (ie number of threads, I think)
#SBATCH --nodes=1 #Number of nodes
#SBATCH --ntasks=1 # Number of MPI ranks (ie number of processes, I think)
#SBATCH --mem-per-cpu=8G #Not sure if I should mess with these...
#SBATCH --mem=64G #Not sure if I should mess with these...
# Partition:
## Since you want to run it on 72 cores, the partition good_cpu has nodes with 72 cores.
#SBATCH --partition=good_lab_reincarnation
##SBATCH -w, --nodelist=compute-0-4 # run on a specific node
#
## Command(s) to run:
chr="14" #"X" #"Y" #"5" #"14"
chr_len=$(cat "chr${chr}_length.txt") #171031299 #91744698 #151834684

#Append chromosome to gene names in file names for autosomal ampliconic families
#Script looks for chromosome name in gene names; works well for sex chromosomes (ex: slX, slY) but not so much for autosomal gene families (speer and atakusan)
if [ "${chr}" == "5" ]; then
	mv speer.kmer_mapping_counts.txt speer5.kmer_mapping_counts.txt
	mv speer_101bp_bowtie2_k500.sam speer5_101bp_bowtie2_k500.sam
elif [ "${chr}" == "14" ]; then
	mv atakusan.kmer_mapping_counts.txt atakusan14.kmer_mapping_counts.txt
	mv atakusan_101bp_bowtie2_k500.sam atakusan14_101bp_bowtie2_k500.sam
fi

#Loop through kmer mapping counts for every gene
echo "Getting informative sites for all genes on chromosome ${chr} of length ${chr_len}"
ls *${chr,,}*.kmer_mapping_counts.txt | while read file; do #All ampliconic genes on chr
	gene=$(echo "${file}" | cut -d "." -f 1)
	echo "${gene}"
	#Get the most frequently occuring # times mapped
	most_freq=$(awk '{print $2}' "${file}" | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
	echo "${most_freq}"
	#Get all kmers that occur exactly the most frequent number of times (informative kmers)
	awk -v mf=$most_freq '$2 == mf { print $0 }' "${file}" > "${gene}.kmer_mapping_counts.informative_only.txt"
	###OLD:Convert ampliconic gene kmer IDs to chromosome locations
	#sly_start=$(grep "Sly" ../../GRCm38_VERSIONS/sly.99.whole_gene.sorted.bed | awk '{print $2}')
	#echo "${sly_start}"
	###^OLD
done

#Merge together informative kmers for all genes
echo "Merging informative kmers across all ampliconic genes..."
cat *${chr,,}*.kmer_mapping_counts.informative_only.txt | sort | uniq > all_genes_chr${chr}.kmer_mapping_counts.informative_only.txt

#Merge together Bowtie2 mapping output for all genes
echo "Merging bam files from mapping kmers from all ampliconic genes..."
ls *${chr,,}*_101bp_bowtie2_k500.sam > "chr${chr}_101bp_bowtie2_k500.file_list.txt"
samtools merge -@ 8 -b "chr${chr}_101bp_bowtie2_k500.file_list.txt" "chr${chr}_101bp_bowtie2_k500.sam"

#Loop through every location in in Y - if part encompassed in an informative kmer (kmer_mapping_counts.informative_only.txt) INFORMATIVE = 1, else 0
#THIS SHOULD REPLACE parse_geneFamily_informativeSites.py from Amplicone
#Ensembl gene locations are 1 based but bed files are 0 based; python script accounts for this
echo "Getting informative sites..."
#python 06_parse_informative_sites.py --GENEFAM ${sly_start} --LENGTH ${chr_len}
#python 06_parse_informative_sites.full_bam.py -s "chr${chr}_101bp_bowtie2_k500.sam" -g gene_definition_mm10.pID95.chrY.tab -c ${chr} -l ${chr_len}
python 06_parse_informative_sites.full_bam.py -s "chr${chr}_101bp_bowtie2_k500.sam" -c ${chr} -l ${chr_len}

echo "Done!"
