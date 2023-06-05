#!/usr/bin/env bash

while getopts i:m:o: flag
do
	case "${flag}" in
		i) infile=${OPTARG};;
		m) masterfile=${OPTARG};;
		o) outfile=${OPTARG};;
	esac
done

awk -F '|' 'NR==FNR { a[$2]; next } FNR==1 || $2 in a { print $0 }' $infile $masterfile > $outfile