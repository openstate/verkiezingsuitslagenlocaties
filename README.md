# Verkiezingsuitslagenlocaties
Instructies en scripts om EML verkiezingsuitslagen die de Kiesraad publiceert te verrijken met stembureaulocaties van https://WaarIsMijnStemlokaal.nl/data.

## Dependencies
- https://github.com/bwbroersma/csv2json
    - clone the repo, `cd` into it and run `cargo build`
- jq
- xsltproc

## Instructies
- Maak een nieuwe `stm_lookup.json` en `stm_lookup2.json` op basis van de stembureaudata (`.csv`) van 'Waar is mijn stemlokaal' (hieronder wordt als voorbeeld de `.csv` van de 2021TK verkiezingen gebruikt https://ckan.dataplatform.nl/datastore/dump/eb2c1546-7f8d-41d4-9719-61b53b6d2111):
    - `cat eb2c1546-7f8d-41d4-9719-61b53b6d2111.csv | <PATH_TO_CSV2JSON>/target/debug/csv2json -t -l | jq -s 'map({N:.["Nummer stembureau"],S:.["Naam stembureau"],P:.["Postcode"],L:.["Plaats"],X:[.["Longitude"],.["Latitude"]],G:.["CBS gemeentecode"]})|group_by(.G)|map({key:.[0].G,value:map({key:.N|tostring,value:.})|group_by(.key)|map({key:.[0].key, value:map(.value|{S,P,L,X})})|from_entries})|from_entries' > stm_lookup.json`
    - `cat eb2c1546-7f8d-41d4-9719-61b53b6d2111.csv | <PATH_TO_CSV2JSON>/target/debug/csv2json -t -l | jq -s 'map({N:.["Nummer stembureau"],S:.["Naam stembureau"],P:.["Postcode"],L:.["Plaats"],X:[.["Longitude"],.["Latitude"]],G:.["CBS gemeentecode"]})|group_by(.G)|map({key:.[0].G,value:map({key:.P|tostring,value:.})|group_by(.key)|map({key:.[0].key, value:map(.value|{S,L,X})|unique})|from_entries})|from_entries' > stm_lookup2.json`

- Plaats de `.eml.xml` bestanden van alle gemeenten in de `eml` folder

- Run `./eml2geojson.sh` (duurt minuutje), waarna alle data per gemeente als `.geojson` bestanden in de `geojson` folder terecht komen

- Run `./add_locations_to_geojson.sh` (duurt paar minuten), waarna alles `.geojson` bestanden verrijkt worden met locaties en in de `geojson_with_loc/geojson` folder terechtkomen

- Run `./create_final_geojson.sh`, waarna alles `.geojson` bestanden samengevoegd worden in 1 bestand: `verkiezingsuitslagenlocaties.geo.json`

- Run `./stembureaus_zonder_loc.py` om `stembureaus_zonder_loc.csv` te maken waar stembureaus in staan die geen locaties hebben; deze kunnen via bv. een cloud spreadsheet door een team ingevuld worden

- Download het handmatig aangevulde `stembureaus_zonder_loc.csv` bestand en noem het `stembureaus_zonder_loc_filled.csv` en run `./csv_locations2geojson.py` waarna de locaties worden toegevoegd en opgeslagen in `verkiezingsuitslagenlocaties_filled.geo.json`

## Notes
- Volgens mij haalden we eerder de opkomstcijfers eruit? (was dat omdat die enkel deels in de CSV zaten en niet in de EML? dus niet relevant voor recente verkiezingen?)
    - `grep -v '    "Opkomst' verkiezingsuitslagenlocaties_filled.geo.json > verkiezingsuitslagenlocaties_filled_zonder_opkomst.geo.json`

- Soms geeft `verkiezingsuitslagenlocaties.geo.json` errors. Bekijk dan het `.json` bestand dat problemen geeft. Het kan bv. zijn dat er bij sommige stembureau 'description'-velden tabs ipv spaties gebruikt worden. Pas dat dan aan.
