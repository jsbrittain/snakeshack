#!/usr/bin/env bash

rm -rf build.zip build
source /Users/jsb/repos/jsbrittain/phyloflow/backend/venv/bin/activate
python -c "import builder; builder.BuildFromFile('workflow_local.json');"
rm build.zip

mkdir build/resources

pushd build

snakemake --d3dag
snakemake --dag | dot -Tsvg > dag.svg
open dag.svg

snakemake --list
snakemake -np

### ISSUE - TODO - Specified default target ###
snakemake --cores 4 --use-conda vocpl_treetime_target

popd
deactivate
