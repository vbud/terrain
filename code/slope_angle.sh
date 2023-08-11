#! /usr/bin/env bash

dir="data"
while getopts d: flag
do
    case "${flag}" in
        d) dir=${OPTARG};;
    esac
done

# Before running this script, download tiles from USGS for the area you are interested in.
# Example below uses California bbox
# python code/download.py --bbox="-124.41060660766607, 32.5342307609976, -114.13445790587905, 42.00965914828148"

# create seamless DEM
gdalbuildvrt $dir/dem.vrt $dir/raw/*.tif

# generate slope
gdaldem slope -s 111120 $dir/dem.vrt $dir/slope.tif

# generate color relief
gdaldem color-relief -alpha -nearest_color_entry $dir/slope.tif color_relief.txt $dir/color_relief.tif

# cut into tiles to preview locally (not required if you just want to upload mbtiles directly)
# gdal2tiles.py --processes 10 --tilesize=512 $dir/color_relief.tif $dir/color_relief_tiles

# convert tif to mbtiles
# ZLEVEL sets the level of compression
gdal_translate -co "ZLEVEL=9" -of mbtiles $dir/color_relief.tif $dir/color_relief.mbtiles

#  let GDAL figure out and generate the lesser zoom levels based on the existing max zoom level
gdaladdo -r nearest $dir/color_relief.mbtiles
