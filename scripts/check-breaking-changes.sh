#!/usr/bin/env bash

PACKAGES=$(lerna list -p -l)
PACKAGE_NAMES=()
EXIT_CODE=0
MESSAGE=""
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
ENDCOLOR=$(tput sgr0)

# Loop through packages
while IFS= read -r line; do

    # Read package info
    IFS=':' read -ra ADDR <<< "$line"
    PACKAGE_PATH="${ADDR[0]}"
    PACKAGE_NAME="${ADDR[1]}"
    PACKAGE_VERSION="${ADDR[2]}"

    # Calculate current and previous package paths / names
    PREV="$PACKAGE_NAME@canary"
    CURRENT="$PACKAGE_PATH/dist/"


    # Run the comparison and record the exit code
    echo ""
    echo ""
    echo "${PACKAGE_NAME}"
    echo "================================================="
    node ./tools/poc3/index.js compare --prev $PREV --current $CURRENT

    # Check if the comparison returned with a non-zero exit code
    # Record the output, maybe with some additional information
    STATUS=$?

    # Final exit code
    # (non-zero if any of the packages failed the checks) 
    if [ $STATUS -gt 0 ]
    then
        EXIT_CODE=1
        MESSAGE="${MESSAGE}${RED} ✘ ${PACKAGE_NAME}: possible breaking changes${ENDCOLOR}\n"    
    else 
        MESSAGE="${MESSAGE}${GREEN} ✔ ${PACKAGE_NAME}: no breaking changes\n${ENDCOLOR}"    
    fi    

done <<< "$PACKAGES"

# Final message
echo -e "\n\n"
echo -e $MESSAGE
exit $EXIT_CODE
