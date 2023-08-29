#!/bin/bash
REF=../ref


run_pipeline(){
CWD=$(pwd)
FQZ1=$1
REF=$2
FQZ2=$(echo $FQZ1 | sed 's/_1./_2./')
FQ1=$(echo $FQZ1 | sed 's/.gz$/-trimmed-pair1.fastq/')
FQ2=$(echo $FQZ1 | sed 's/.gz$/-trimmed-pair2.fastq/')
BASE=$(echo $1 | sed 's/.fastq.gz//')
BAM=/home/ziemannm/barry/map/$BASE.bam

# SKEWER Version 0.2.2 (updated in April 4, 2016), Author: Hongshan Jiang
skewer -t $(nproc) -q 20 $FQZ1 $FQZ2

#Spliced Transcripts Alignment to a Reference (c) Alexander Dobin, 2009-2020
#STAR version=2.7.10a
#STAR compilation time,server,dir=2022-01-16T16:35:44+00:00 <place not set in Debian package>
#For more details see:<https://github.com/alexdobin/STAR>
STAR --runThreadN 30 \
  --quantMode GeneCounts \
  --genomeLoad LoadAndKeep  \
  --outSAMtype BAM Unsorted \
  --limitBAMsortRAM 20000000000 \
  --genomeDir $REF \
  --readFilesIn=$FQ1 $FQ2 \
  --outFileNamePrefix $BASE.

rm $FQ1 $FQ2
}
export -f run_pipeline

parallel -j1 run_pipeline ::: *_1.fastq.gz ::: $REF

STAR --genomeLoad Remove --genomeDir $REF

for TAB in *ReadsPerGene.out.tab ; do
  tail -n +5 $TAB | cut -f1,4 | sed "s/^/${TAB}\t/"
done | pigz > 3col.tsv.gz

# sort bam files
# samtools 1.13
# Using htslib 1.13+ds
for BAM in *bam ; do
  NAME=$(echo $BAM | sed 's/_1.Aligned.out//')
  samtools sort  -@ 6 -o $NAME $BAM && rm $BAM
done

ls *bam | parallel samtools index {}
