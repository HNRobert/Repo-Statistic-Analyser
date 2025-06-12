#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Parse command line arguments
MAX_FILES=""
TARGET_PATH=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -l)
            MAX_FILES="$2"
            shift 2
            ;;
        -p)
            TARGET_PATH="$2"
            shift 2
            ;;
        *)
            # If it's not a flag, treat as path
            if [[ -z "$TARGET_PATH" && -d "$1" ]]; then
                TARGET_PATH="$1"
                shift
            else
                echo "Usage: $0 [-l <max-file-count>] [-p <path>] [path]"
                echo "  -l: Limit number of files to display"
                echo "  -p: Target directory path"
                echo "  path: Target directory path (alternative to -p)"
                exit 1
            fi
            ;;
    esac
done

# Change to target directory if specified
if [[ -n "$TARGET_PATH" ]]; then
    if [[ ! -d "$TARGET_PATH" ]]; then
        echo -e "${RED}Error: Directory '$TARGET_PATH' does not exist${NC}"
        exit 1
    fi
    cd "$TARGET_PATH" || {
        echo -e "${RED}Error: Cannot change to directory '$TARGET_PATH'${NC}"
        exit 1
    }
    echo -e "${CYAN}Analyzing repository in: ${BOLD}$(pwd)${NC}"
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

echo -e "${YELLOW}-----------------------------------------${NC}"
echo -e "${YELLOW}|${CYAN}  Git Tracked File Line Count Summary  ${YELLOW}|${NC}"
echo -e "${YELLOW}-----------------------------------------${NC}"

git ls-files -z | xargs -0 wc -l | tee /tmp/wc_output | awk -v GREEN="$GREEN" -v BOLD="$BOLD" -v NC="$NC" -v MAX_FILES="$MAX_FILES" '
    BEGIN {
        total = 0; count = 0
    }
    /^[[:space:]]*[0-9]+[[:space:]]+/ && $2 != "total" {
        files[count] = $0
        total += $1; count++
    }
    END {
        if (MAX_FILES == "" || count <= MAX_FILES) {
            # Display all files
            for (i = 0; i < count; i++) {
                split(files[i], parts)
                printf "%s%6d%s %s\n", GREEN, parts[1], NC, parts[2]
            }
        } else {
            # Display first (MAX_FILES-1) files
            for (i = 0; i < MAX_FILES - 1; i++) {
                split(files[i], parts)
                printf "%s%6d%s %s\n", GREEN, parts[1], NC, parts[2]
            }
            # Display "..." if there are hidden files
            if (count > MAX_FILES) {
                printf "   ··· (%d files hidden)\n", count - MAX_FILES
            }
            # Display last file
            split(files[count-1], parts)
            printf "%s%6d%s %s\n", GREEN, parts[1], NC, parts[2]
        }
        
        printf "\n%sTotal files:%s %s%d%s\n", BOLD, NC, GREEN, count, NC
        printf "%sTotal lines:%s %s%d%s\n", BOLD, NC, GREEN, total, NC
    }
'
