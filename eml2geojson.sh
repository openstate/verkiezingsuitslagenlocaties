#!/bin/bash

cd eml
for file in *
do
    new_name=$(echo "$file" | sed 's/.eml.xml$/.json/');
    echo "$new_name";
    xsltproc ../telling-simple.xslt "$file" > "../geojson/$new_name"
done
