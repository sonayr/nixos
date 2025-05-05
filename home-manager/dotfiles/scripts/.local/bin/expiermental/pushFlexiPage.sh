#!/bin/bash

if [[ $1 != *"flexipage-meta"* ]]; then
   echo "Needs to run on a flexipage" 
   exit 1
fi

retrieve_reports () {
    echo yoo
    echo "${@}"
    results=()
    for arg in "${@}"; do
        results+=(report:/$arg)
    done
    
   reports=$(sf project retrieve start -m ${results[@]} -o nesto  --json | jq -r '.result.files[].filePath')
   echo ${reports[@]}
} 

export -f retrieve_reports
retrieve_dashboards () {
    results=()
   for arg in "${@}"; do
       results+=(dashboard:/$arg)
   done
   dashboards=$(sf project retrieve start -m ${results[@]} -o nesto  --json | jq -r '.result.files[].filePath')
   echo "${dashboard[1]}"
    for dashboard in "${dashboards[@]}"; do 
        echo hey
        echo $dashboard
        xmlstarlet sel -N N="http://soap.sforce.com/2006/04/metadata" -t \
            -v "//N:report" \
            $dashboard \
        | xargs bash -c 'retrieve_reports "$@"' _
    done
   # echo ${reports[@]}
}

export -f retrieve_dashboards
xmlstarlet sel -N N="http://soap.sforce.com/2006/04/metadata" -t \
    -v "//N:componentInstanceProperties/N:name[text() = 'dashboardName']/following-sibling::N:value" $1 \
    | xargs bash -c 'retrieve_dashboards "$@"' _


