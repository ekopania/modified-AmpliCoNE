#PURPOSE: Generate commands to count the number of times kmers map using parallel

import sys, os, re, datetime

############################################################

#Print the bash shebang line so the output can be read as a bash script to run commands one at a time if necessary
print("#!/bin/bash")

#A descriptive message about what these commands are
print("# kmer count command generator")

#Specify both the location of the input files and the desired location for the output files.
#indir = "DATA/MAPPED/PRJEB11742_MAPPED/"
#outdir = "PROCESSED_BAMS/PRJEB11742_PROCESSED/"
# Specify both the location of the input files and the desired location for the output files.

#Always good to include some runtime info for records
print("# PYTHON VERSION: " + ".".join(map(str, sys.version_info[:3])))
print("# Script call: " + " ".join(sys.argv))
print("# Runtime: " + datetime.datetime.now().strftime("%m/%d/%Y %H:%M:%S"))
#print("# Input directory: " + indir)
#print("# Output directlory: " + outdir)
print("# ----------");

#Read in command line arguments
if(len(sys.argv) != 2):
        sys.exit("Enter an ampliconic gene name")

gene = str(sys.argv[1])
print("#Generating commands for ampliconic gene:" + gene)

my_kmers=open(gene+".kmer_names.txt","r")
for line in my_kmers:
	kmer=line.strip()
	#print("echo \"" + kmer + "\"")
	count_command="mycount=$(grep -c -P \"" + kmer + "\\t\" " + gene + "_101bp_bowtie2_k500.sam)"
	echo_command="echo \"" + kmer + "\t${mycount}\" >> " + gene + ".kmer_mapping_counts.txt"
	print(count_command + "; " + echo_command)
