#!/bin/bash

# Check for the environment and branch name parameters
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <env> <branch_name>"
  echo "<env> should be either 'uat' or 'prod'"
  echo "<branch_name> is the name of the current branch"
  exit 1
fi

ENV=$1
# Sanitize the branch name to ensure it's compliant with Docker's tag naming conventions
BRANCH_NAME=$(echo "$2" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

# Load version properties
. ./version.properties

VERSION=${version:-"unknown"}
LATEST=${latest:-"latest"}
NAME=${IMAGE_NAME:-"ftron"}

# Adjust the version if not on the main branch by appending the sanitized branch name
if [ "$BRANCH_NAME" != "main" ]; then
  VERSION="${VERSION}-${BRANCH_NAME}"
fi

# Base name for the image
BASE_NAME="${NAME}:${VERSION}"

# Adjust tags based on environment
UAT_TAG="${BASE_NAME}-uat"
UAT_LATEST_TAG="${BASE_NAME}-uat-latest"
PROD_TAG="${BASE_NAME}-prod"
PROD_LATEST_TAG="${BASE_NAME}-prod-latest"

echo "Image tags to be pushed based on the environment: $ENV"

# Conditional push logic
if [ "$ENV" = "uat" ]; then
  echo "UAT Version: ${UAT_TAG}"
  echo "UAT Latest: ${UAT_LATEST_TAG}"
  
  docker push ${DOCKER_REPO}/${UAT_TAG} || exit 1
  docker push ${DOCKER_REPO}/${UAT_LATEST_TAG} || exit 1

elif [ "$ENV" = "prod" ]; then
  echo "PROD Version: ${PROD_TAG}"
  echo "PROD Latest: ${PROD_LATEST_TAG}"
  
  docker push ${DOCKER_REPO}/${PROD_TAG} || exit 1
  docker push ${DOCKER_REPO}/${PROD_LATEST_TAG} || exit 1

else
  echo "Invalid environment specified. Please choose either 'uat' or 'prod'."
  exit 1
fi

echo "Push done for the $ENV environment with sanitized branch name: $BRANCH_NAME"
