#!/bin/bash
##PURPOSE: Generate gene definition files per chromosome for AmpliCoNE 
# Job name:
#SBATCH --job-name=gene_definition
#SBATCH --output=gene_definition.pID97.chr14.log
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=ekopania4@gmail.com # Where to send mail
#SBATCH --cpus-per-task=1 # Number of cores per MPI rank (ie number of threads, I think)
#SBATCH --nodes=1 #Number of nodes
#SBATCH --ntasks=1 # Number of MPI ranks (ie number of processes, I think)
#SBATCH --mem-per-cpu=8G #Not sure if I should mess with these...
#SBATCH --mem=96000 #Not sure if I should mess with these...
# Partition:
## Since you want to run it on 72 cores, the partition good_cpu has nodes with 72 cores.
#SBATCH --partition=good_lab_cpu
##SBATCH -w, --nodelist=compute-0-4 # run on a specific node
#
## Command(s) to run:
#variable for chromosome
chr="14" #lower case
#variable for percent ID
pID=97
echo "These are the chromosome and percent ID for this run: ${chr} ${pID}"

#create output file and append header
echo "START	END	TYPE" > gene_definition_mm10.pID${pID}.chr${chr^^}.tab

#get starts and stops for each control gene for chr
echo "Looping through control genes..."
cat ../control_genes.${chr^^}.txt | while read gene; do
        zcat /mnt/beegfs/ek112884/REFERENCE_DIR/mm10.refGene.gtf.gz | grep ${gene} | grep -P "refGene\ttranscript" > temp.gtf
        cat temp.gtf | awk '{print $4 "\t" $5}' | uniq - > ${gene}.tab
        sed -i "s/$/\tCONTROL/" ${gene}.tab
        cat gene_definition_mm10.pID${pID}.chr${chr^^}.tab ${gene}.tab > temp.tab
        rm gene_definition_mm10.pID${pID}.chr${chr^^}.tab
        mv temp.tab gene_definition_mm10.pID${pID}.chr${chr^^}.tab
        rm ${gene}.tab
        rm temp.gtf
done

#parse blast hit table for each amplicon family for $chr
echo "Looping through ampliconic gene families..."
ls /mnt/beegfs/ek112884/cnvs/*${chr}*_blast_results_1-ResultsTable-Mus_musculus_Tools_Blast_.csv | while read file; do
	gene_fam=$(echo "${file}" | cut -d "/" -f 6 | cut -d "_" -f 1)
	echo ${gene_fam}
	#Gets starts and end positions for genes with percent ID > pID and evalue = 0.0
	Rscript 01_parse_blast_hittable.r ${file} ${chr^^} ${pID}
	#Append gene family name in all caps (^^)
	sed -i "s/$/\t${gene_fam^^}/" temp_starts_ends.txt
	cat gene_definition_mm10.pID${pID}.chr${chr^^}.tab temp_starts_ends.txt > temp.tab
	rm gene_definition_mm10.pID${pID}.chr${chr^^}.tab
	mv temp.tab gene_definition_mm10.pID${pID}.chr${chr^^}.tab
	rm temp_starts_ends.txt
done

echo "Done!"
