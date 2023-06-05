#!/usr/bin/env bash

while getopts i:o: flag
do
	case "${flag}" in
		i) infile=${OPTARG};;
		o) outdir=${OPTARG};;
	esac
done

nextalign run --input-ref="./resources/reference.fasta" --$genemap="./resources/genemap.gff" --genes="E,M,N,ORF1a,ORF1b,ORF3a,ORF6,ORF7a,ORF7b,ORF8,ORF9b,S" --output-all=$infile $infile
