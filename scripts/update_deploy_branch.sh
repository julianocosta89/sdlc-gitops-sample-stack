#!/bin/bash

# Usage: ./prepare_argo_release.sh NEW_VERSION ENV BRANCH_NAME
# Example: ./prepare_argo_release.sh 123 dev deploy

set -e

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 NEW_VERSION ENV BRANCH_NAME"
  exit 1
fi

NEW_VERSION="$1"
ENV="$2"
BRANCH_NAME="$3"

# Define the script path for updating the manifests
SCRIPTS_DIR=${BASH_SOURCE%/*}
UPDATE_SCRIPT="${SCRIPTS_DIR}/update_manifests_for_release.sh"

# Only switch branches and merge if the branch is not 'main'
if [ "$BRANCH_NAME" != "main" ]; then
  # Checkout the specified branch and merge main into it
  git checkout "$BRANCH_NAME"
  git pull origin "$BRANCH_NAME"
  git merge origin/main
fi

# Run the update script
$UPDATE_SCRIPT "$NEW_VERSION" "$ENV"

# Commit and push changes
git add "manifests/overlays/${ENV}/kustomization.yaml"
git commit -m "Updated environment: ${ENV} with version ${NEW_VERSION}"
git push origin "$BRANCH_NAME"

echo "Pushed changes to branch: ${BRANCH_NAME}"