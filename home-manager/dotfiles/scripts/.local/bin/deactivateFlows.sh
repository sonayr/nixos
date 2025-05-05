#!/bin/bash

apiName=$(basename $1 | grep -E "^[^.]+" -o)
echo $apiName
flowDefinitionPath=$(sf project retrieve start -m flowDefinition:$apiName --json | jq -r '.result.files[0].filePath')
echo $flowDefinitionPath
xmlstarlet edit -L -N w="http://soap.sforce.com/2006/04/metadata" \
    -u "/w:FlowDefinition/w:activeVersionNumber"\
    -v 0 \
    $flowDefinitionPath

sf project deploy start -d $flowDefinitionPath
rm $flowDefinitionPath
