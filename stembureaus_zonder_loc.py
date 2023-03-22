#!/usr/bin/env python3

import csv
import json

with open('verkiezingsuitslagenlocaties.geo.json') as IN:
    data = json.load(IN)

with open('stembureaus_zonder_loc.csv', 'w') as OUT:
    writer = csv.writer(OUT)
    writer.writerow(['gmcode', 'Stembureau', 'Locatie', 'Adres', 'description', 'latitude', 'longitude'])
    for x in data['features']:
        if x['geometry']['coordinates'][0] == 0:
            writer.writerow(
                [
                    x['properties']['gmcode'],
                    x['properties']['Stembureau'],
                    x['properties']['Locatie'],
                    x['properties']['Adres'],
                    x['properties']['description'],
                    x['geometry']['coordinates'][0],
                    x['geometry']['coordinates'][1]
                ]
            )
