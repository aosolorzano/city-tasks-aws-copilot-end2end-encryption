#!/bin/bash

cd "$WORKING_DIR" || {
  echo "Error moving to the application's root directory."
  exit 1
}

echo ""
echo "DELETING COPILOT APP FROM AWS..."
copilot app delete --yes

### DELETING AUTOMATED SCRIPTS
sh "$WORKING_DIR"/utils/scripts/helper/1_revert-automated-scripts.sh
echo ""
echo "DONE!"
