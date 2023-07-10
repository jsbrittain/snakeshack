#!/usr/bin/env bash

rm -rf build.zip build
source /Users/jsb/repos/jsbrittain/phyloflow/backend/venv/bin/activate
python -c "import builder; builder.BuildFromFile('workflow_local.json');"
rm build.zip

mkdir build/resources

pushd build


######################################
### THINGS THAT NEED AUTOMATING... ###
######################################

# Default target (need dynamic targets; also default target)
echo "

rule target:
    input:
        \"results/vocpl_nextalign_4/s123456/nextalign.aligned.fasta\"
    default_target: True" >> workflow/Snakefile

# Resources and scripts are inaccessible
mkdir resources
# cp ../sources/provide_seeds/resources/seeds.txt resources/seeds.txt
ln -s ~/Desktop/ex_input resources
ln -s ex_input/beta.metadata.tsv resources/beta.metadata.tsv
ln -s ex_input/beta.fasta resources/beta.fasta
ln -s ../modules/subsample_ids_metadata/scripts scripts
cp ../../../../../joetsui1994/vocpl/resources/nov_sars-cov-2/* resources

######################################








snakemake --d3dag
snakemake --dag | dot -Tsvg > dag.svg
open dag.svg
popd
deactivate
