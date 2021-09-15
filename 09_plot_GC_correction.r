#PURPOSE: Plot average depth by %GC and GC correction curve as in QuicKmer2 to compare AmpliCoNE's GC correction with that of QuicKmer2

print("Reading in data...")
depth_by_gc<-read.table("amplicone.WDIScombined.pID95.OWN_METHOD.kmerStartOnly.log", skip=27, nrows=99, header=FALSE)
print(dim(depth_by_gc))
print(head(depth_by_gc))
print(tail(depth_by_gc))

gc_cor<-scan("GC_correction_output.txt")

depth_by_gc$V1<-as.numeric(as.character(depth_by_gc$V1))
depth_by_gc$V2<-as.numeric(as.character(depth_by_gc$V2))

pdf("GC_plot.pdf", width=11, height=8.5)
plot(x=depth_by_gc$V1, y=depth_by_gc$V2, type="l", col="blue", main="Depth by %GC and GC Correction - Amplicone", xlab="%GC", ylab="Average Depth", ylim=c(0,5))
lines(x=depth_by_gc$V1, y=gc_cor, col="red")
axis(4)
mtext("GC Correction Curve", side=4, line=3)
dev.off()
