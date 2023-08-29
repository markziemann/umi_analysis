#!/bin/bash

# download
for RUN in $(cat SRR_Acc_List.txt) ; do
  prefetch --max-size 999999999999999999 -p -O . $RUN
done

# unpack the fastq files
for SRA in *sra ; do
  fastq-dump --split-files $SRA
done

# map with star to mouse genome
# Gencode Release M33 (GRCm39)

