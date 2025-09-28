#!/bin/bash

# Check for the environment and branch name parameters
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <env> <branch_name>"
  echo "<env> should be either 'uat' or 'prod'"
  echo "<branch_name> is the name of the current branch"
  exit 1
fi

ENV=$1
BRANCH_NAME=$(echo "$2" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

  . ./version.properties

VERSION=${version:-"unknown"}
LATEST=${latest:-"latest"}
NAME=${IMAGE_NAME:-"ftron"}

# Adjust the version if not on the main branch
if [ "$BRANCH_NAME" != "main" ]; then
  VERSION="${VERSION}-${BRANCH_NAME}"
fi

# Base name for the image
BASE_NAME="${NAME}:${VERSION}"

# UAT and Prod specific tags
UAT_TAG="${BASE_NAME}-uat"
UAT_LATEST_TAG="${BASE_NAME}-uat-latest"
PROD_TAG="${BASE_NAME}-prod"
PROD_LATEST_TAG="${BASE_NAME}-prod-latest"

echo "Image tags to be generated based on the environment: $ENV"

# Conditional Build Logic
if [ "$ENV" = "uat" ]; then
  echo "UAT Version: ${UAT_TAG}"
  echo "UAT Latest: ${UAT_LATEST_TAG}"

  CMD="docker build --pull -t ${UAT_TAG} -t ${UAT_LATEST_TAG} -f docker/compile/Dockerfile ."
  echo "$CMD"
  $CMD || exit 1

elif [ "$ENV" = "prod" ]; then
  echo "Prod Version: ${PROD_TAG}"
  echo "Prod Latest: ${PROD_LATEST_TAG}"

  CMD="docker build --pull -t ${PROD_TAG} -t ${PROD_LATEST_TAG} -f docker/prod/compile/Dockerfile ."
  echo "$CMD"
  $CMD || exit 1

else
  echo "Invalid environment specified. Please choose either 'uat' or 'prod'."
  exit 1
fi

echo "Build done for the $ENV environment with sanitized branch name."

