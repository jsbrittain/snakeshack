#!/usr/bin/env bash

while getopts i:o: flag
do
	case "${flag}" in
		i) infile=${OPTARG};;
		o) outfile=${OPTARG};;
	esac
done

awk -F '\t' '{ print $2 }' <(tail -n +2 $infile) > $outfile
