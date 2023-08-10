# Slope angle raster tile creation guide

```bash
# only necessary if using a fresh terminal session
source active terrain
# download tiles from USGS for given bounding box
# use --high_res for high-resolution tiles
# bbox is California
python code/download.py --bbox="-124.41060660766607, 32.5342307609976, -114.13445790587905, 42.00965914828148"
# create seamless DEM
gdalbuildvrt data/dem.vrt data/raw/*.tif
# generate slope
gdaldem slope -s 111120 data/dem.vrt data/slope.tif
# generate color relief
gdaldem color-relief -alpha -nearest_color_entry data/slope.tif color_relief.txt data/color_relief.tif
# cut into tiles
gdal2tiles.py --processes 10 --tilesize=512 data/color_relief.tif data/color_relief_tiles
# convert tif to mbtiles
# ZLEVEL sets the level of compression
gdal_translate -co "ZLEVEL=9" -of mbtiles data/color_relief.tif data/color_relief.mbtiles
#  let GDAL figure out and generate the lesser zoom levels based on the existing max zoom level
gdaladdo -r nearest data/color_relief.mbtiles
```
