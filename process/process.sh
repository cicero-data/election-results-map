rm -rf _output

mkdir _output _output/mbtiles

# Export to GeoJSON
mapshaper -i input/state_upper.geojson -simplify 0.2 -o _output/state_upper_polygons.geojson format=geojson
mapshaper -i input/state_lower.geojson -simplify 0.2 -o _output/state_lower_polygons.geojson format=geojson

# Generate Labels
geojson-polygon-labels --style=largest _output/state_upper_polygons.geojson > _output/state_upper_points.geojson
geojson-polygon-labels --style=largest _output/state_lower_polygons.geojson > _output/state_lower_points.geojson

# Generate vector tiles
tippecanoe -pk -f -o _output/mbtiles/state_upper_polygons.mbtiles --no-tile-compression --minimum-zoom=1 --maximum-zoom=8 --generate-ids --detect-shared-borders _output/state_upper_polygons.geojson
tippecanoe -pk -f -o _output/mbtiles/state_upper_points.mbtiles --no-tile-compression --minimum-zoom=1 --maximum-zoom=8 --generate-ids -r1 _output/state_upper_points.geojson
tippecanoe -pk -f -o _output/mbtiles/state_lower_polygons.mbtiles --no-tile-compression --minimum-zoom=1 --maximum-zoom=8 --generate-ids --detect-shared-borders _output/state_lower_polygons.geojson
tippecanoe -pk -f -o _output/mbtiles/state_lower_points.mbtiles --no-tile-compression --minimum-zoom=1 --maximum-zoom=8 --generate-ids -r1 _output/state_lower_points.geojson

# Merge all mbtiles files into one
tile-join -pk -o _output/mbtiles/combined.mbtiles _output/mbtiles/state_upper_polygons.mbtiles _output/mbtiles/state_upper_points.mbtiles _output/mbtiles/state_lower_polygons.mbtiles _output/mbtiles/state_lower_points.mbtiles --no-tile-compression

# Export mbtiles file into z/y/x file structure
mb-util --image_format=pbf _output/mbtiles/combined.mbtiles _output/tiles
