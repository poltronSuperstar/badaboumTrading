#!/bin/zsh

# ANSI Color Codes for fancy output
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NO_COLOR='\033[0m'

# Set the repository directory
REPO_DIR="/var/badaboum/badaboumTrading"

# Enter the repository directory
cd $REPO_DIR

# Continuous sync loop
while true; do
    echo "${CYAN}Fetching latest changes from the remote...${NO_COLOR}"
    git fetch --all

    # Check for local uncommitted changes and stash them
    if [[ -n $(git status --porcelain) ]]; then
        echo "${MAGENTA}Stashing local changes...${NO_COLOR}"
        git stash push -u -m "Auto-stashed by sync script"
        STASH_APPLIED=1
    fi

    # Merge changes from remote, prioritizing content inclusion
    echo "${BLUE}Merging changes from ${REMOTE_BRANCH}...${NO_COLOR}"
    git merge --no-ff --strategy-option=theirs origin/main

    if [[ $? -eq 0 ]]; then
        echo "${GREEN}Merge successful. Local repository is up-to-date with remote.${NO_COLOR}"
    else
        echo "${RED}Merge conflicts detected! Attempting automatic resolution by favoring combined changes...${NO_COLOR}"
        git merge --strategy-option=theirs
        if [[ $? -eq 0 ]]; then
            echo "${GREEN}Conflicts resolved automatically, and changes merged successfully.${NO_COLOR}"
        else
            echo "${RED}Unable to resolve conflicts automatically. Manual intervention required.${NO_COLOR}"
            break
        fi
    fi

    # Reapply stashed changes if there were any
    if [[ $STASH_APPLIED -eq 1 ]]; then
        echo "${MAGENTA}Reapplying stashed changes...${NO_COLOR}"
        git stash pop
        if [[ -n $(git status --porcelain) ]]; then
            echo "${RED}Conflicts detected after reapplying stashed changes! Please resolve manually.${NO_COLOR}"
        else
            echo "${GREEN}Stashed changes reapplied successfully.${NO_COLOR}"
        fi
        unset STASH_APPLIED
    fi

    # Sleep for 2 seconds before the next poll
    echo "${YELLOW}Sleeping for 2 seconds...${NO_COLOR}"
    sleep 2
done
