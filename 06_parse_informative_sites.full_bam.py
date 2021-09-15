#!/usr/bin/python
import sys
import argparse
import pysam
import re
from Bio import SeqIO

parser=argparse.ArgumentParser(
    description='''Parse mapability scores and expand them to position specific values. ''')
parser.add_argument('--SAM', '-s', required=True, help='SAM file. (Aligned using BOWTIE2) ', metavar='<SAM>')
#parser.add_argument('--GENEDEF', '-g', required=True, help='Gene definition file. (List of genes in gene family location) ', metavar='<SAM>')
#parser.add_argument('--CHR', '-c', required=True, help=' Chromosome annotation as found in the SAM header file. ', choices=['Y','chrY'])
parser.add_argument('--CHR', '-c', required=True, help=' Chromosome annotation as found in the SAM header file. ')
parser.add_argument('--LENGTH','-l', type=int, required=True, help='Length of the Y chromosome in the reference.')
	
args=parser.parse_args()

SAM=args.SAM #SAM file. (Aligned using BOWTIE2)
CHR=args.CHR #chromosome name as defined in the SAM Y or chrY
len_chr=args.LENGTH #Length of Y chromosome in reference
#GENE_DEFINITION=args.GENEDEF

# GENE_DEFINITION='gene_definition_new.tab'
# CHR='Y'
# SAM='Ychr_101bp_hg38_k15_sorted.bam' #'Ychr_bowtie2_k15_101mer.bam'
# len_chr=57227415

#Reading the gene definition file
#Family_location={}
#with open(GENE_DEFINITION, "rU") as g: 
#  #Expand the cigar string 
#  header=g.next()	#START	END	FAMILY
#  for line in g:
#	col=line.rstrip('\n').split("\t") 
#	if col[2] in Family_location:
#		Family_location[col[2]].append([col[0],col[1]])
#	else:
#		Family_location[col[2]]=[[col[0],col[1]]]


#Reading the SAM file to generate table with a list of read names and all the locations it mapped to.
Yposition_mapcount={}
with pysam.AlignmentFile(SAM, "r") as bamfile:
	j,i=0,0
	for read in bamfile.fetch():
		if read.flag !=4:
			if read.cigarstring == '101M':
				if read.get_tag("NM")<=2:
					if read.query_name in Yposition_mapcount:
						#print read.query_name, read.flag, read.reference_name, read.reference_start+1, read.cigarstring, read.get_tag("NM")
						Yposition_mapcount[read.query_name].append(str(read.reference_name)+":"+str(read.reference_start+1))
					else:
						Yposition_mapcount[read.query_name]=[(str(read.reference_name)+":"+str(read.reference_start+1))]
		else:
			if read.query_name in Yposition_mapcount:
				Yposition_mapcount[read.query_name].append('NA')
			else:
				Yposition_mapcount[read.query_name]=['NA']
#print(Yposition_mapcount)
#exit()		

#Identify informative sites by parsing reads that mapped to each gene within a family as a set and save it as a dictionary
#Family_list_readMapped={}
#for genefamily in Family_location:
#	if genefamily.upper()=='CONTROL':
#		continue
#	elif len(Family_location[genefamily])==1 : #skip if gene family has only one gene
#			continue
#	else:
#		f_size=len(Family_location[genefamily])
#		eachgene_readMapped_perlocation={}
#		#print genefamily
#		for i in range(f_size):
#			gene_start=int(Family_location[genefamily][i][0])
#			gene_end=int(Family_location[genefamily][i][1])
#			gene_index=xrange(gene_start,gene_end+1)
#			id_gene=str(genefamily)+"_"+str(gene_start)+"_"+str(gene_end)
#			#print id_gene
#			eachgene_readMapped_perlocation[id_gene]=[]
#			temp_list=[]
#			for j in gene_index:
#				k=str(CHR)+"_"+str(j) # NOTE: It should match the read names in SAM file
#				temp_list.append(sorted(Yposition_mapcount[k]))
#			eachgene_readMapped_perlocation[id_gene]=set(tuple(i) for i in temp_list)
#		Family_list_readMapped[genefamily]=eachgene_readMapped_perlocation

#For each family label the position that has the number of reads mapped to it equals the size of family and found in all copies as 1 otherwise 0
print("Parsing sites")
Genefamily_output=open(str(CHR)+"_Informative_list_GeneFamily.tab","w")
InfoKmers=open("all_genes_chr"+str(CHR)+".kmer_mapping_counts.informative_only.txt","r")
informative_kmers=InfoKmers.read()
informative_sites = [0]*len_chr
#for key in Family_list_readMapped:
for key in Yposition_mapcount:
	#print(key)
	if (key in informative_kmers):
	#Intersect sets of reads mapped to genes in gene family 
#	info_sites=reduce(set.intersection,Family_list_readMapped[key].values())
		info_sites=Yposition_mapcount[key]
#		size=len(Family_location[key])
		for k in info_sites:
			#print(k)
#			if len(k)==size:
#			x=list(k)
#			x.append(key)
			x=k+"\t"+key
#			Genefamily_output.write(str('\t'.join(x)+"\n"))
			Genefamily_output.write(x+"\n")
			this_chr=k.split(":")[0]
			j=k.split(":")[1] 
#			for l in range(int(j),int(j)+101):	
#				informative_sites[l-1]=1 #Coverting read location 1 based to python 0 based by subtracting one here; mark whole kmer (101mer) as informative
			if (this_chr == "chr"+str(CHR)): #Make sure mapping is to the correct chromosome
				informative_sites[int(j)-1]=1 #Coverting read location 1 based to python 0 based by subtracting one here; just mark kmer start location as informative and NOT whole kmer

Genefamily_output.close()


informative_output=open(str(CHR)+"_Informative_101bp.tab","w")
informative_output.write("Informative_Sites\n")
for index in range(len(informative_sites)):
	informative_output.write(str(informative_sites[index])+ "\n")

informative_output.close()
