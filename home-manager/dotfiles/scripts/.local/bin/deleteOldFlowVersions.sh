#!/bin/bash

sf force data soql query \
    --query "SELECT Id FROM Flow WHERE Status != 'Active'"\
    --use-tooling-api \
    --result-format csv > delete_oldFlows.csv
while read c; do
    if [[ "$c" != "Id" && "$c" != "Your query returned no results." ]]
        then
            sf data record delete --sobject Flow --record-id $c --use-tooling-api
    fi
done < delete_oldFlows.csv
rm delete_oldFlow.csv 
