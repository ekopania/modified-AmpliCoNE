#PURPOSE: Read in blast hit table and filter based on parameters such as percent ID and evalue; save gene list
#NOTE: Blast hit tables downloaded from Ensembl blast search online
#NOTE: Script 02 should call this Rscript

args<-commandArgs(TRUE)
if(length(args) != 3){
        stop("Missing command line arguments. Enter the file name of a blast hit table, a chromosome, and a threshold cutoff for percent ID to consider a gene a paralog (Enter the percent NOT the proportion i.e. 95 not 0.05).")
}

print("Reading in and sorting blast hit table...")
mydata<-read.csv(args[1],header=TRUE)
print(dim(mydata))
print(head(mydata))
sorted_by_pid<-mydata[order(-as.numeric(as.character(mydata$X.ID))),]
print(dim(sorted_by_pid))
print(head(sorted_by_pid))
print(tail(sorted_by_pid))

print("Extracting paralogs above %ID threshold cutoff...")
thresh<-as.numeric(args[3])
print(thresh)
gt_thresh<-sorted_by_pid[intersect(which(as.numeric(as.character(sorted_by_pid$X.ID))>thresh),which(as.numeric(as.character(sorted_by_pid$E.val))==0.0)),]
print(dim(gt_thresh))
print(head(gt_thresh))
print(tail(gt_thresh))

print("Getting start and end positions")
loc<-gt_thresh$Genomic.Location
ranges<-sapply(loc, function(x) sub("^[[:alnum:]]*:","",x))
chrs<-sapply(loc, function(x) gsub(":[[:alnum:]]*-[[:alnum:]]*","",x))
starts<-sapply(ranges, function(x) gsub("-\\d*$","",x))
ends<-sapply(ranges, function(x) gsub("^\\d*-","",x))
start_end_all<-as.data.frame(cbind(starts,ends))

print("Removing paralogs that are not on expected chromosome...")
keep<-c()
for(i in 1:length(chrs)){
	#print(chrs[i])
	if(chrs[i]==args[2]){
		keep<-c(keep,i)
	}
}

start_end<-start_end_all[keep,]

print("Writing to file...")
write.table(start_end,file="temp_starts_ends.txt",sep="\t",quote=FALSE,col.name=FALSE,row.name=FALSE)

print("Done with 01_parse_blast_hittable.r")
