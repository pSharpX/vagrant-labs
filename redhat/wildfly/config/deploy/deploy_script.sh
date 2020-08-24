function ExecuteDeployment {
    echo "Checking current deployment, whether 'blue' or 'green' is running"
    BLUE=`curl -S -H "Content-Type: application/json" -d '{"operation":"read-attribute", "name":"runtime-name", "address":[{"deployment":"our_assembly.war"}]}' --digest ${WF_MANAGEMENT_URL} | sed -ne "s/.*outcome\" *: *\"\([a-zA-Z]\+\).*/\1/p"`
 
    if [ "${BLUE}" == "success" ]; then
        OLD_DEPLOY=our_assembly.war
        NEW_DEPLOY=ALT_our_assembly.war
        mv ${TMPDIR}/our_assembly.war ${TMPDIR}/${NEW_DEPLOY}
        echo "BLUE deployment active, new WAR name will be; ${NEW_DEPLOY}"
    else
        OLD_DEPLOY=ALT_our_assembly.war
        NEW_DEPLOY=our_assembly.war
        echo "GREEN deployment active, new WAR name will be; ${NEW_DEPLOY}"
    fi
 
    echo "Undeploy old war"
    curl -S -H "content-Type: application/json" -d '{"operation":"undeploy", "address":[{"deployment":"'${OLD_DEPLOY}'"}]}' --digest ${WF_MANAGEMENT_URL}
    echo ""
 
    echo "Upload new war from $TMPDIR/$NEW_DEPLOY"
    BYTES_VALUE=`curl -F "file=@${TMPDIR}/${NEW_DEPLOY}" --digest ${WF_MANAGEMENT_URL}/add-content | perl -pe 's/^.*"BYTES_VALUE"\s*:\s*"(.*)".*$/$1/'`
    echo ""
 
    JSON_STRING_START='{"content":[{"hash": {"BYTES_VALUE" : "'
    JSON_STRING_END='"}}], "address": [{"deployment":"'${NEW_DEPLOY}'"}], "runtime-name":"'${WAR_FILE}'", "operation":"add", "enabled":"true"}'
    JSON_STRING="${JSON_STRING_START}${BYTES_VALUE}${JSON_STRING_END}"
 
    echo "Deploy new war"
    RESULT=`curl -S -H "Content-Type: application/json" -d "${JSON_STRING}" --digest ${WF_MANAGEMENT_URL} | sed -ne "s/.*outcome\" *: *\"\([a-zA-Z]\+\).*/\1/p"`
    echo "Deployment result: ${RESULT}"
    echo ""
 
    if [ "${RESULT}" == "success" ]; then
    	echo "Remove old war"
        curl -S -H "content-Type: application/json" -d '{"operation":"remove", "address":[{"deployment":"'${OLD_DEPLOY}'"}]}' --digest ${WF_MANAGEMENT_URL}
        echo ""
    else
	echo "Deployment failed! Try reverting to old deployment"
    	curl -S -H "content-Type: application/json" -d '{"operation":"undeploy", "address":[{"deployment":"'${NEW_DEPLOY}'"}]}' --digest ${WF_MANAGEMENT_URL}
        curl -S -H "content-Type: application/json" -d '{"operation":"remove", "address":[{"deployment":"'${NEW_DEPLOY}'"}]}' --digest ${WF_MANAGEMENT_URL}
    	curl -S -H "content-Type: application/json" -d '{"operation":"deploy", "address":[{"deployment":"'${OLD_DEPLOY}'"}]}' --digest ${WF_MANAGEMENT_URL}
    	echo ""
    fi
}