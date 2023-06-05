#!/usr/bin/env bash

while getopts i:m:o: flag
do
	case "${flag}" in
		i) infile=${OPTARG};;
		m) masterfile=${OPTARG};;
		o) outfile=${OPTARG};;
	esac
done

seqkit grep -n -f $infile $masterfile > $outfile