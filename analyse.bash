#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${YELLOW} -----------------------------------${NC}"
echo -e "${YELLOW}|${CYAN}Git Tracked File Line Count Summary${YELLOW}|${NC}"
echo -e "${YELLOW} -----------------------------------${NC}"

git ls-files -z | xargs -0 wc -l | tee /tmp/wc_output | awk -v GREEN="$GREEN" -v BOLD="$BOLD" -v NC="$NC" '
  BEGIN {
    total = 0; count = 0
  }
  /^[[:space:]]*[0-9]+[[:space:]]+/ && $2 != "total" {
    total += $1; count++
    printf "%s%6d%s %s\n", GREEN, $1, NC, $2
  }
  END {
    printf "\n%sTotal files:%s %s%d%s\n", BOLD, NC, GREEN, count, NC
    printf "%sTotal lines:%s %s%d%s\n", BOLD, NC, GREEN, total, NC
  }
'
