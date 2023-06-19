#!/usr/bin/env bash

set -eoux pipefail

# Source
. /Users/jsb/repos/jsbrittain/phyloflow/backend/venv/bin/activate

# Sleep2
python -c "import builder; builder.BuildFromFile('sleep2.json')"
rm -rf sleep2
mv build sleep2

# Sleep2_3
python -c "import builder; builder.BuildFromFile('sleep2_3.json')"
rm -rf sleep2_3
mv build sleep2_3

# Sleep2_3_recon
python -c "import builder; m=builder.ImportWorkflowDir('sleep2_3'); m.SaveWorkflow()"
rm -rf sleep2_3_recon
mv build sleep2_3_recon

# Sleep3
python -c "import builder; builder.BuildFromFile('sleep3.json')"
rm -rf sleep3
mv build sleep3

# Sleep3_3
python -c "import builder; builder.BuildFromFile('sleep3_3.json')"
rm -rf sleep3_3
mv build sleep3_3

# Sleep3_3_recon
python -c "import builder; m=builder.ImportWorkflowDir('sleep3_3'); m.SaveWorkflow()"
rm -rf sleep3_3_recon
mv build sleep3_3_recon

# Tidy-up
rm build.zip
