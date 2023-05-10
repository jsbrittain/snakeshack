
SCRIPT_DIR="$(dirname -- "$(readlink -f – "$0")";)"
pushd $SCRIPT_DIR

if [ ! $# -eq 1 ]
then
    echo "Script must be run with exactly one parameter: 'new_workflow_name'"
    exit 1
fi

WORKFLOW=$1
echo "Creating workflow template: $WORKFLOW"
cp -r template $WORKFLOW

popd
