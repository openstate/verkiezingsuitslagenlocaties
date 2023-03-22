#!/usr/bin/env python3

import csv
import json

with open('verkiezingsuitslagenlocaties.geo.json') as IN:
    data = json.load(IN)

cnt = 0
with open('stembureaus_zonder_loc_filled.csv') as IN:
    reader = csv.reader(IN)
    # Skip headers
    next(reader)
    for line in reader:
        for x in data['features']:
            if line[0] == x['properties']['gmcode'] and line[3] == x['properties']['Adres'] and line[4] == x['properties']['description'] and x['geometry']['coordinates'][0] == 0:
                latitude = 0
                if line[5].replace(',', '.').strip() != "0":
                    latitude = float(line[5].replace(',', '.').strip())
                longitude = 0
                if line[6].replace(',', '.').strip() != "0":
                    longitude = float(line[6].replace(',', '.').strip())
                x['geometry']['coordinates'] = [longitude, latitude]
                cnt += 1

with open('verkiezingsuitslagenlocaties_filled.geo.json', 'w', encoding="utf-8") as OUT:
    json.dump(data, OUT, indent=2, ensure_ascii=False)
