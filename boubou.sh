#!/bin/zsh

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NO_COLOR='\033[0m'

# Set the repository directory
REPO_DIR="/var/badaboum/badaboumTrading"

# Enter the repository directory
cd $REPO_DIR

# Continuous sync loop
while true; do
    echo "${YELLOW}Fetching latest changes from the remote...${NO_COLOR}"
    git fetch --all
    
    # Check for local uncommitted changes
    if [[ -n $(git status --porcelain) ]]; then
        echo "${RED}Uncommitted changes detected! Resetting to match remote...${NO_COLOR}"
        git reset --hard origin/master
    else
        echo "${GREEN}No local changes detected.${NO_COLOR}"
    fi

    # Check for remote changes and local commit differences
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    BASE=$(git merge-base @ @{u})

    if [ $LOCAL = $REMOTE ]; then
        echo "${GREEN}Up-to-date with remote. No action required.${NO_COLOR}"
    elif [ $LOCAL = $BASE ]; then
        echo "${YELLOW}Pulling latest changes...${NO_COLOR}"
        git pull
        echo "${GREEN}Pull successful.${NO_COLOR}"
    elif [ $REMOTE = $BASE ]; then
        echo "${YELLOW}Local changes need to be pushed. Resetting to remote...${NO_COLOR}"
        git reset --hard origin/master
        git pull
    else
        echo "${RED}Divergence detected, resetting local changes to match remote...${NO_COLOR}"
        git reset --hard origin/master
    fi

    # Sleep for 2 seconds before the next poll
    echo "${YELLOW}Sleeping for 2 seconds...${NO_COLOR}"
    sleep 2
done
