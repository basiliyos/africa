# http://www.naturalearthdata.com/downloads/
NATURAL_EARTH_CDN = http://naciscdn.org/naturalearth

all: ../data/africa.rda

.SECONDARY:

zip/ne_10m_admin_0_countries.zip:
	mkdir -p $(dir $@)
	curl "$(NATURAL_EARTH_CDN)/10m/cultural/ne_10m_admin_0_countries.zip" -o $@.download
	mv $@.download $@

shp/ne_10m_admin_0_countries.shp: zip/ne_10m_admin_0_countries.zip
	mkdir -p $(dir $@)
	unzip -d shp $<
	touch $@

africa-10m.json: shp/ne_10m_admin_0_africa.shp
	topojson \
		-o $@ \
		--shapefile-encoding utf8 \
		--id-property=adm0_a3 \
		-p \
		-- countries=$<

shp/ne_10m_admin_0_africa.shp: shp/ne_10m_admin_0_countries.shp
	ogr2ogr \
	  -sql "SELECT * FROM ne_10m_admin_0_countries WHERE continent = 'Africa'" \
		-f "ESRI Shapefile" \
		$@ \
		$< \
		-lco ENCODING=US-ASCII

../data/africa.rda: africa-10m.json
	R -e 'africa <- rgdal::readOGR(dsn = "shp/ne_10m_admin_0_africa.shp", layer = "ne_10m_admin_0_africa"); devtools::use_data(africa, overwrite = TRUE)'

clean:
	rm -rf shp zip africa-10m.csv africa-10m.json ../data/africa.rda
