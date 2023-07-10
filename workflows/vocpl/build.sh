#!/usr/bin/env bash

rm -rf build.zip build
source /Users/jsb/repos/jsbrittain/phyloflow/backend/venv/bin/activate
python -c "import builder; builder.BuildFromFile('workflow.json');"
rm build.zip

mkdir build/resources
cp sources/provide_seeds/resources/seeds.txt build/resources/

pushd build
snakemake --d3dag
snakemake --dag | dot -Tsvg > dag.svg
open dag.svg
popd
deactivate
