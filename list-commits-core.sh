#!/bin/bash

# Check if the required number of arguments is provided
if [ $# -lt 4 ]; then
    echo "Usage: $0 AUTHOR LOWER_DATE UPPER_DATE REPO_FOLDER..."
    exit 1
fi

# Set variables
AUTHOR="${1}"
LOWER_DATE="${2}"
UPPER_DATE="${3}"

# Function to print header with dynamic hash tags
print_header() {
    local repo_name="$1"
    local header="# Processing repository: $repo_name #"
    local header_length=${#header}
    local line=$(printf '#%.0s' $(seq 1 $header_length))

    echo "$line"
    echo "$header"
    echo "$line"
}

# Iterate over each repository folder passed as an argument
for REPO_FOLDER in "${@:4}"; do

    # Extract the repository name from the folder path
    REPO_NAME=$(basename "$REPO_FOLDER")

    # Print the header
    print_header "$REPO_NAME"

    # Check if the directory exists and is a git repository
    if [ ! -d "$REPO_FOLDER" ] || [ ! -d "$REPO_FOLDER/.git" ]; then
        echo "Error: $REPO_FOLDER is not a valid Git repository"
        continue
    fi

    # Change to the specified Git repository directory
    cd "$REPO_FOLDER" || continue

    # Fetch updates from the remote repository
    echo "Fetching updates for $REPO_NAME..."
    git fetch --all --quiet

    # Variable to track if any commits were found in the repo
    COMMITS_FOUND=false

    # Convert SSH URL to HTTPS URL
    REPO_URL=$(git config --get remote.origin.url)
    if [[ "$REPO_URL" == git@* ]]; then
        BASE_URL="https://"$(echo "$REPO_URL" | sed -e 's/:/\//' -e 's/git@//g' -e 's/\.git$//')
    else
        BASE_URL=$(echo "$REPO_URL" | sed 's/\.git$//')
    fi

    # Iterate over branches
    for BRANCH in $(git branch -r | grep -v HEAD); do

        # Count the commits by the author in this branch within the date range
        COMMIT_COUNT=$(git log "$BRANCH" --author="$AUTHOR" --since="$LOWER_DATE" --until="$UPPER_DATE" | wc -l)

        if [ "$COMMIT_COUNT" -gt 0 ]; then
            COMMITS_FOUND=true
            echo "🡒 Branch: $BRANCH"

            # Display commits with exact time and HTTPS links
            git log "$BRANCH" --author="$AUTHOR" --since="$LOWER_DATE" --until="$UPPER_DATE" --date=local --pretty=format:"%h %s [%ad] (Link: $BASE_URL/commit/%H)"
            echo # Add a newline for readability
        fi
    done

    # Check if no commits were found in any branch of the repo
    if [ "$COMMITS_FOUND" = false ]; then
        echo "No commit for this repo"
    fi

done
