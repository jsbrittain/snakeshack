#!/usr/bin/env bash

while getopts i:o: flag
do
	case "${flag}" in
		i) infile=${OPTARG};;
		o) outfile=${OPTARG};;
	esac
done

awk -F '\t' '{ if ($4 == "good") print $1 }' $infile > $outfile
