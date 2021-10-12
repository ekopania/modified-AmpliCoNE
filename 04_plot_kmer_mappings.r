#PURPOSE: Plot histogram of counts of kmer mappings

args<-commandArgs(TRUE)
if(length(args) != 1){
        stop("Missing command line argument. Enter the name of a kmer mapping count file")
}

indata<-read.table(args[1], header=FALSE, col.names=c("kmer_name","mapping_count"))
print(head(indata))
kmer_num<-unlist(lapply(indata$kmer_name, function(x) gsub("^chr._","",x)))
print(head(kmer_num))
newdata<-as.data.frame(cbind(kmer_num, indata))
mydata<-newdata[order(as.numeric(as.character(newdata$kmer_num))),]
print(head(mydata))
gene_name<-gsub("_.*","",args[1])
print(gene_name)
pdf(paste0(gene_name,".kmer_mapping_hist.pdf"), onefile=TRUE)
hist(as.numeric(as.character(mydata$mapping_count)), main="Histogram of 101-mers mapping to mouse Y", xlab="# time 101mer maps to mouse Y")
plot(as.numeric(as.character(mydata$mapping_count)), main=paste("Plot of # times mapped vs",gene_name,"start location\nBowtie2 -k 500"), xlab=paste("Start location of 101-mer within",gene_name), ylab="# times mapped to mouse Y")
abline(h=334, lty=2)
abline(h=309, lty=2)
abline(h=207, lty=2)
abline(h=112, lty=2)
abline(h=22, lty=2)
dev.off()

print("Done with 04_plot_kmer_mappings.r")
