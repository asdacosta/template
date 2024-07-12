#!/bin/bash

USERNAME="" 
REPO="" 
# Get all deployments
deployments=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/$USERNAME/$REPO/deployments)
# Extract the ID of the most recent deployment, assuming first deployment is the most recent
deployment_id=$(echo "$deployments" | jq -r '.[0].id')  
# Activate the most recent deployment
gh api --method POST -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$USERNAME/$REPO/deployments/$deployment_id/statuses \
  -F state=success

# Iterate over all deployments and delete them if they are not active
for deployment_id in $(echo "$deployments" | jq -r '.[].id'); do
  is_active=$(echo "$deployments" | jq -r --arg deployment_id "$deployment_id" '.[] | select(.id == $deployment_id) | .state')
  
  if [ "$is_active" != "active" ]; then
    echo "Deleting deployment ID: $deployment_id"
    gh api --method DELETE -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/$USERNAME/$REPO/deployments/$deployment_id
  else
    echo "Skipping active deployment ID: $deployment_id"
  fi
done
