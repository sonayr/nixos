#! /bin/bash
for file in force-app/main/default/flexipages/*
do
    xmlstarlet ed -L -N N="http://soap.sforce.com/2006/04/metadata" \
        -d "//N:itemInstances[./N:componentInstance/N:componentInstanceProperties/N:name[text() = 'dashboardName']]" \
        $file
done
