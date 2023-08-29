#!/bin/bash
#need to have the ensembl GTF and FA file in current dir
GTF=gencode.vM33.primary_assembly.annotation.gtf
FA=GRCm39.primary_assembly.genome.fa
CWD=$(pwd)

STAR --runMode genomeGenerate \
  --sjdbGTFfile $GTF \
  --genomeDir $CWD  \
  --genomeFastaFiles $CWD/$FA \
  --runThreadN $(nproc)
