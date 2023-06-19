#!/usr/bin/env bash

set -eoux pipefail

# Source
. /Users/jsb/repos/jsbrittain/phyloflow/backend/venv/bin/activate

# Sleep2
python -c "import builder; builder.BuildFromFile('sleep2l.json')"
rm -rf sleep2l
mv build sleep2l

# Sleep2_3
python -c "import builder; builder.BuildFromFile('sleep2_3l.json')"
rm -rf sleep2_3l
mv build sleep2_3l

# Sleep2_3_recon
python -c "import builder; m=builder.ImportWorkflowDir('sleep2_3l'); m.SaveWorkflow()"
rm -rf sleep2_3l_recon
mv build sleep2_3l_recon

# Sleep3
python -c "import builder; builder.BuildFromFile('sleep3l.json')"
rm -rf sleep3l
mv build sleep3l

# Sleep3_3
python -c "import builder; builder.BuildFromFile('sleep3_3l.json')"
rm -rf sleep3_3l
mv build sleep3_3l

# Sleep3_3_recon
python -c "import builder; m=builder.ImportWorkflowDir('sleep3_3l'); m.SaveWorkflow()"
rm -rf sleep3_3l_recon
mv build sleep3_3l_recon

# Tidy-up
rm build.zip
