#!/bin/zsh

# ANSI Color Codes for enhanced readability
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NO_COLOR='\033[0m'

# Repository directory and branch names
REPO_DIR="/var/badaboum/badaboumTrading"
LOCAL_BRANCH="local-branch"  # Name of your local branch
MAIN_BRANCH="main"           # Name of the main branch on the remote

# Enter the repository directory
cd $REPO_DIR

# Ensure the local branch exists and create it from main if it doesn't
if ! git rev-parse --verify $LOCAL_BRANCH >/dev/null 2>&1; then
    echo "${MAGENTA}Local branch $LOCAL_BRANCH does not exist. Creating from $MAIN_BRANCH...${NO_COLOR}"
    git fetch origin
    git checkout -b $LOCAL_BRANCH origin/$MAIN_BRANCH
else
    # Ensure local branch is checked out
    git checkout $LOCAL_BRANCH
fi

# Continuous sync loop
while true; do
    echo "${CYAN}Fetching latest changes from $MAIN_BRANCH...${NO_COLOR}"
    git fetch origin $MAIN_BRANCH

    echo "${BLUE}Merging changes from origin/${MAIN_BRANCH} into $LOCAL_BRANCH...${NO_COLOR}"
    git merge origin/$MAIN_BRANCH -m "Auto-merge of origin/${MAIN_BRANCH} into $LOCAL_BRANCH"

    if [[ $? -eq 0 ]]; then
        echo "${GREEN}Merge successful. ${LOCAL_BRANCH} is now up-to-date with origin/${MAIN_BRANCH}.${NO_COLOR}"
        
        # Now pushing from local-branch to main explicitly
        echo "${MAGENTA}Pushing merged changes from $LOCAL_BRANCH to origin/${MAIN_BRANCH}...${NO_COLOR}"
        git push origin $LOCAL_BRANCH:$MAIN_BRANCH
        if [[ $? -eq 0 ]]; then
            echo "${GREEN}Push successful. Changes are now live on origin/${MAIN_BRANCH}.${NO_COLOR}"
        else
            echo "${RED}Failed to push changes. Check your network settings or permissions.${NO_COLOR}"
        fi
    else
        echo "${RED}Merge conflicts detected! Attempting automatic resolution by favoring combined changes...${NO_COLOR}"
        git merge --strategy-option=union
        if [[ $? -eq 0 ]]; then
            echo "${GREEN}Conflicts resolved automatically, and changes merged successfully.${NO_COLOR}"
        else
            echo "${RED}Unable to resolve conflicts automatically. Manual intervention required.${NO_COLOR}"
            break
        fi
    fi

    echo "${YELLOW}Sleeping for 2 seconds...${NO_COLOR}"
    sleep 2
done
#c caca