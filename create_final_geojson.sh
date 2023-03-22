#!/bin/bash

jq -s '{type:"FeatureCollection",features:map(.features)|flatten|sort_by(.properties.election)}' geojson_with_loc/geojson/*.json > verkiezingsuitslagenlocaties.geo.json
