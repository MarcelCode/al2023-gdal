#!/bin/bash

version=$(gdal-config --version)
echo Running tests for GDAL ${version}

echo "Checking formats"
if [[ ! "$(gdal-config --prefix | grep $PREFIX)" ]]; then echo "NOK" && exit 1; fi
if [[ ! "$(gdal-config --formats | grep 'GTIFF')" ]]; then echo "GTIFF NOK" && exit 1; fi
if [[ ! "$(gdal-config --formats | grep 'geojson')" ]]; then echo "GeoJson NOK" && exit 1; fi
echo "OK"

echo "Checking sqlite build"
if [[ ! "$(ldd $PREFIX/bin/gdalwarp | grep $PREFIX/lib/libsqlite3)" ]]; then echo "libsql NOK" && exit 1; fi
echo "OK"

echo "Checking OGR"
if [[ ! "$(ogrinfo /local/tests/fixtures/map.geojson | grep 'successful')" ]]; then echo "NOK" && exit 1; fi
if [[ ! "$(ogrinfo /local/tests/fixtures/POLYGON.shp | grep 'successful')" ]]; then echo "NOK" && exit 1; fi
echo "OK"

echo "Checking PROJ_NETWORK:"
if [[ ! "$(PROJ_NETWORK=ON projinfo --remote-data | grep 'Status: enabled')" ]]; then echo "NOK" && exit 1; fi
if [[ ! "$(projinfo --remote-data | grep 'Status: disabled')" ]]; then echo "NOK" && exit 1; fi
echo "OK"

echo "Checking Reading COG"
if [[ ! "$(gdal_translate /local/tests/fixtures/cog.tif /tmp/tmp.tif | grep "done.")" ]]; then echo "NOK" && exit 1; fi
echo "OK"

exit 0
