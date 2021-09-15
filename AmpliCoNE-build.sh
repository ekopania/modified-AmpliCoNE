#!/bin/bash
#EK on 14 January 2021: Commented out steps 5 and 6 (Bowtie and parse informative sites); using own method to do this based on most common # of times kmer maps per gene family, instead of # of genes in gene family given in gene annotation file
#Also changed usage() to usage on line 35 to match proper python syntax

set -e

usage(){ echo "Usage:	$0 -c chrY|Y -i <REF.fasta> -m <REF-MAPPABILITY.bed> -r <REF-REPMASK.out> -t <REF-TRF.bed> -g <Gene_Definition.tab> -o chrY_annotation.tab -s <start_step>

	-c	chromosome name as in reference (Y or chrY): ${chromosome} 
	-i	reference file (download from UCSC Genome Browser)
	-m	GEM-MAPPABILITY output in bed format 
	-r	RepeatMasker output (download from UCSC Genome Browser)
	-t	TandemRepeatFinder output (download from UCSC Genome Browser)
	-g	geneDefinition 
	-o	output file name
	-s	step to start Amplicone-build.sh at
	"
	1>&2; exit 1; }


while getopts c:i:m:r:t:g:o:s: option
do
case "${option}"
in
c) chromosome=${OPTARG};;
i) reference=${OPTARG};;
m) mappability=${OPTARG};;
r) repeatmasker=${OPTARG};;
t) tandemRepeatFinder=${OPTARG};;
g) geneDefinition=${OPTARG};;
o) output=${OPTARG};;
s) start_step=${OPTARG};;
esac
done

if [ -z "${chromosome}" ] || [ -z "${reference}" ] || [ -z "${mappability}" ] || [ -z "${repeatmasker}" ] || [ -z "${tandemRepeatFinder}" ] || [ -z "${geneDefinition}" ] || [ -z "${output}" ] || [ -z "${start_step}" ]; then
    usage
fi

echo "INPUT:
	chromosome: ${chromosome} 
	reference: ${reference} 
	mappability: ${mappability}
	repeatmasker: ${repeatmasker}
	tandemRepeatFinder: ${tandemRepeatFinder}
	geneDefinition: ${geneDefinition}
	output: ${output}
	starting step: ${start_step}"


#check if the software exists
hash bowtie2 2>/dev/null || { echo "I require bwa in path but it's not installed.  Aborting."; exit 1; }


#check if the python scripts are available
if [ ! -f "bin/calculate_Ychr_GCpercent_and_generate101bp_reads.py" ]; then
    echo "ERROR: bin/calculate_Ychr_GCpercent_and_generate101bp_reads.py not found!"
    exit 1;
fi
if [ ! -f "bin/parse_Ychr_Mappability.py" ]; then
    echo "ERROR: bin/analyzeRepeats.py not found!"
    exit 1;
fi
if [ ! -f "bin/parse_Ychr_RepeatMasker.py" ]; then
    echo "ERROR: bin/parse_Ychr_RepeatMasker.py not found!"
    exit 1;
fi
if [ ! -f "bin/parse_Ychr_TRF.py" ]; then
    echo "ERROR: bin/parse_Ychr_TRF.py not found!"
    exit 1;
fi
if [ ! -f "bin/parse_geneFamily_informativeSites.py" ]; then
    echo "ERROR: bin/parse_geneFamily_informativeSites.py not found!"
    exit 1;
fi
if [ ! -f "bin/generate_summary_annotationFile.py" ]; then
    echo "ERROR: bin/generate_summary_annotationFile.py not found!"
    exit 1;
fi


echo "\n\nChecking if input files exist"

if [ ! -f ${reference} ]; then
    echo "ERROR: Reference file :${reference} not found!"
    exit 1;
fi
if [ ! -f ${mappability} ]; then
    echo "ERROR: Mappability output file :${mappability} not found!"
    exit 1;
fi
if [ ! -f ${repeatmasker} ]; then
    echo "ERROR: RepeatMasker output file :${repeatmasker} not found!"
    exit 1;
fi
if [ ! -f ${tandemRepeatFinder} ]; then
    echo "ERROR: TandemRepeatFinder output file :${tandemRepeatFinder} not found!"
    exit 1;
fi
if [ ! -f ${geneDefinition} ]; then
    echo "ERROR: GeneDefinition file :${geneDefinition} not found!"
    exit 1;
fi


#########################################Pipeline starts here
#USE THIS PARAMETERS TO DEBUG AND RUN FROM A PARTICULAR STEP 
STEP=${start_step}
#LEVEL='SUMMARY'

#case $LEVEL in
#        "GC_READS")
#                STEP=1;;
#        "MAPPABILITY")
#                STEP=2;;
#        "RM")
#                STEP=3;;
#        "TRF")
#                STEP=4;;
#        "BOWTIE2")
#                STEP=5;;
#        "INFO")
#                STEP=6;;
#        "SUMMARY")
#                STEP=7;;
#        *);;
#esac

if [ $STEP -le 1 ]
then
	if [ -f ${reference} ]; then 
		echo "\nGenerating GCcontent and Reads for downstrean analysis." 
		echo "python bin/calculate_Ychr_GCpercent_and_generate101bp_reads.py -r ${reference} -c ${chromosome}"
		python bin/calculate_Ychr_GCpercent_and_generate101bp_reads.py -r ${reference} -c ${chromosome}
	fi
	if [ ! -f ${chromosome}_GC_Content.txt ]; then
		echo "ERROR: ${chromosome}_GC_Content.txt file  was not generated by bin/calculate_Ychr_GCpercent_and_generate101bp_reads.py. Check input files for this step."
		exit 1;
	fi
	if [ ! -f ${chromosome}_length.txt ]; then
		echo "ERROR: ${chromosome}_length.txt file  was not generated by bin/calculate_Ychr_GCpercent_and_generate101bp_reads.py. Check input files for this step."
		exit 1;
	fi
	if [ ! -f ${chromosome}_Sliding_window101bp_Reference_reads.fasta ]; then
		echo "ERROR: Sliding_window101bp_Reference_reads.fasta file  was not generated by bin/calculate_Ychr_GCpercent_and_generate101bp_reads.py. Check input files for this step."
		exit 1;
	fi
fi

if [ -f ${chromosome}_length.txt ]; then 
		echo "\nObtaining chromosome length." 
		chr_len=$(cat "${chromosome}_length.txt")
fi

if [ $STEP -le 2 ]
then
	if [ -f ${mappability} ]; then 
		echo "\nParsing Mappability scores" 
		echo "python bin/parse_Ychr_Mappability.py -i ${mappability} -c ${chromosome} -l ${chr_len}"
		python bin/parse_Ychr_Mappability.py -i ${mappability} -c ${chromosome} -l ${chr_len}
	fi
	if [ ! -f ${chromosome}_MAPPABILITY_bypos.txt ]; then
		echo "ERROR: ${chromosome}_MAPPABILITY_bypos.txt file was not generated by bin/parse_Ychr_Mappability.py. Check input files for this step."
		exit 1;
	fi
fi

if [ $STEP -le 3 ]
then	
	if [ -f ${repeatmasker} ]; then 
		echo "\nParsing repeat masker output" 
		echo "python bin/parse_Ychr_RepeatMasker.py -i ${repeatmasker} -c ${chromosome} -l ${chr_len}"
		python bin/parse_Ychr_RepeatMasker.py -i ${repeatmasker} -c ${chromosome} -l ${chr_len}
	fi
	if [ ! -f ${chromosome}_REPEAT_MASKED.txt ]; then
		echo "ERROR: ${chromosome}_REPEAT_MASKED.txt file was not generated by bin/parse_Ychr_RepeatMasker.py. Check input files for this step."
		exit 1;
	fi
fi

if [ $STEP -le 4 ]
then
	if [ -f ${tandemRepeatFinder} ]; then 
		echo "\nParsing TandemRepeatFinder output" 
		echo "python bin/parse_Ychr_TRF.py -i ${tandemRepeatFinder} -c ${chromosome} -l ${chr_len}"
		python bin/parse_Ychr_TRF.py -i ${tandemRepeatFinder} -c ${chromosome} -l ${chr_len}
	fi
	if [ ! -f ${chromosome}_TANDAMREPEAT_MASKED.txt ]; then
		echo "ERROR: ${chromosome}_TANDAMREPEAT_MASKED.txt file  was not generated by bin/parse_Ychr_TRF.py. Check input files for this step."
		exit 1;
	fi
fi

#if [ $STEP -le 5 ]
#then
#	if [ -f Sliding_window101bp_Reference_reads.fasta ]; then
#		echo "\nGenerating Bowtie2 index and aligning reads"
#		bowtie2-build ${reference} bowtie2_index
#		bowtie2 -k 15 --threads 5 -x bowtie2_index  -f Sliding_window101bp_Reference_reads.fasta -S Ychr_101bp_bowtie2_k15.sam
#	fi
#fi
#
#if [ $STEP -le 6 ]
#then
#	if [ -f Ychr_101bp_bowtie2_k15.sam ]; then
#		echo "\nParse gene family specific informative sites"
#		echo "python bin/parse_geneFamily_informativeSites.py -s Ychr_101bp_bowtie2_k15.sam -g ${geneDefinition} -c ${chromosome} -l ${chr_len}"
#		python bin/parse_geneFamily_informativeSites.py -s Ychr_101bp_bowtie2_k15.sam -g ${geneDefinition} -c ${chromosome} -l ${chr_len}
#	fi
#	if [ ! -f ${chromosome}_Informative_101bp_hg38.tab ]; then
#		echo "ERROR: ${chromosome}_Informative_101bp_hg38.tab file  was not generated by bin/parse_geneFamily_informativeSites.py. Check input files for this step."
#		exit 1;
#	fi
#fi

#if [ $STEP -le 7 ]
if [ $STEP -eq 7 ] #Only run this last step if it is specifically called
then
	echo "\nReading all the parameters. Filtering repeat sites, sites with 0 GCpercent and 0 Mappability score."
#	echo "python bin/generate_summary_annotationFile.py -g ${chromosome}_GC_Content.txt -m ${chromosome}_MAPPABILITY_bypos.txt -r ${chromosome}_REPEAT_MASKED.txt -t ${chromosome}_TANDAMREPEAT_MASKED.txt  -i ${chromosome}_Informative_101bp_hg38.tab -o ${output} -l ${chr_len}\n"
	echo "python bin/generate_summary_annotationFile.py -g ${chromosome}_GC_Content.txt -m ${chromosome}_MAPPABILITY_bypos.txt -r ${chromosome}_REPEAT_MASKED.txt -t ${chromosome}_TANDAMREPEAT_MASKED.txt  -i informative_sites.tab -o ${output} -l ${chr_len}\n"
#	python bin/generate_summary_annotationFile.py -g ${chromosome}_GC_Content.txt -m ${chromosome}_MAPPABILITY_bypos.txt -r ${chromosome}_REPEAT_MASKED.txt -t ${chromosome}_TANDAMREPEAT_MASKED.txt  -i ${chromosome}_Informative_101bp_hg38.tab -o ${output} -l ${chr_len}
#	python bin/generate_summary_annotationFile.py -g ${chromosome}_GC_Content.txt -m ${chromosome}_MAPPABILITY_bypos.txt -r ${chromosome}_REPEAT_MASKED.txt -t ${chromosome}_TANDAMREPEAT_MASKED.txt  -i informative_sites.tab -o ${output} -l ${chr_len}
	python bin/generate_summary_annotationFile.py -g ${chromosome}_GC_Content.txt -m ${chromosome}_MAPPABILITY_bypos.txt -r ${chromosome}_REPEAT_MASKED.txt -t ${chromosome}_TANDAMREPEAT_MASKED.txt  -i informative_sites.tab -o ${output} -l ${chr_len}
	echo "\nGenerated output."
	echo "\nCan delete intermediate files."
fi
