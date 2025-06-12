#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Parse command line arguments
MAX_FILES=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -l)
            MAX_FILES="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 [-l <max-file-count>]"
            exit 1
            ;;
    esac
done

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
