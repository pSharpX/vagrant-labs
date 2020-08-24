 # Get the current memory usage and parse to get percentage
local MEMORY=`curl -S -H "Content-Type: application/json" -d '{"operation":"read-attribute", "name":"non-heap-memory-usage", "address":[{"core-service":"platform-mbean"}, {"type":"memory"}]}' --digest ${WF_MANAGEMENT_URL}`
local MAX=`echo ${MEMORY} | sed -ne "s/.*max\" *: *\([0-9]\+\).*/\1/p"`
local USED=`echo ${MEMORY} | sed -ne "s/.*used\" *: *\([0-9]\+\).*/\1/p"`
local CURRENT_MEM=$(echo "${USED} / ${MAX}" | bc -l)
echo ""
echo "Current non-heap memory percentage in use: ${USED} / ${MAX} = ${CURRENT_MEM}"
echo ""

if (( $(bc <<< "${CURRENT_MEM} < ${WF_MEMORY_TRESHOLD}") == 1 )) ; then
    # Restart not necessary, return
    return
else
    if [ "${ENVIRONMENT}" != "TEST" ] ; then
        # Ask user for permission
        echo ""
        read -t 60 -p "Wildfly restart necessary. To confirm enter the text 'restart' and press [ENTER]: " CONFIRMATION
        CONFIRMATION=${CONFIRMATION^^} # To upper case
        if [ "${CONFIRMATION}" != "RESTART" ]; then
            echo ""
            echo "No confirmation for restart, aborting installation!!!"
            Cleanup
            exit 1
        fi
    fi
fi