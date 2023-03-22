#!/bin/bash

for f in geojson/*.json;
do
    echo "$f";
    jq --slurpfile l nlzipcodes.json --slurpfile s stm_lookup.json --slurpfile p stm_lookup2.json '. as $root | {type:"FeatureCollection",features:.features|map(. as $b | .geometry={type:"Point",coordinates:( ($s[0][$root.municipality][.properties.Stembureau|tostring] | if (length == 1 or $b.properties.Stembureau != 1) then .[0].X else ($s[0][$root.municipality][$b.properties.Adres[0:6]] | if (length == 1) then .[0].X else null end) end) // $l[0][.properties.Adres[0:6]] // [0,0])})|map(.properties.gmcode=$root.municipality)|map(.properties.election=$root.election)|map(.properties.electionName=$root.electionName)}' "$f" > geojson_with_loc/"$f";
done
