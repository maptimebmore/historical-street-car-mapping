# MaptimeBmore Historical Streetcar Mapping project
This README provides a guide for the MaptimeBmore Historical Streetcar Mapping project. The goal of the project is to digitize streetcar routes from the 1896 Bromley atlas of Baltimore City. The map sheets are obtained from the Johns Hopkins Sheridan Library system here: [Atlas of the City of Baltimore Maryland](https://jscholarship.library.jhu.edu/handle/1774.2/35300).

We will be using a free and open source mapping platform:

- [QGIS3](https://qgis.org/en/site/) as a desktop GIS client
- A [Postgres/PostGIS database set up on Heroku](https://www.heroku.com/postgres)
- A basic [NodeJS / Express API and application using Leaflet](https://github.com/jondandois/leaflet-express-tutorial)

### Useful links
- [QGIS3 Docs](https://docs.qgis.org/3.4/en/docs/)
- [Leaflet](https://leafletjs.com/)
- [Node and Express web map](https://developer.mozilla.org/en-US/docs/Learn/Server-side/Express_Nodejs/skeleton_website)
- [Leaflet with PostGIS, NodeJS, and Express: Eric Huntley and Mike Foster](http://duspviz.mit.edu/web-map-workshop/leaflet_nodejs_postgis/)

## Get your environment set up
- Install QGIS3.x LTR
- Optional: Install [Postgres](https://www.postgresql.org/) - You shouldn't need Postgres to work with QGIS and the DB, but it might be helpful later.
- [Connect](https://docs.qgis.org/3.4/en/docs/user_manual/managing_data_source/opening_data.html#database-related-tools) to remote Heroku PostGIS DB and add layer to map in QGIS
- Enable Georeferencing plugin
    - [Georeferencer plugin](https://docs.qgis.org/3.4/en/docs/user_manual/plugins/core_plugins/plugins_georeferencer.html)
    - [Georeferencer Tutorial 1](https://docs.qgis.org/3.4/en/docs/training_manual/forestry/map_georeferencing.html)
    - [Georeferencer Tutorial 2](https://www.qgistutorials.com/en/docs/3/georeferencing_basics.html)
- Add in an OSM Tile layer from the QGIS Browser Pane -> XYZ Tiles -> OpenStreetMap

## Historical Mapping of Streetcar Atlas Sheets
1. Get an image from the [Atlas of the City of Baltimore Maryland](https://jscholarship.library.jhu.edu/handle/1774.2/35300)
2. Start the QGIS Georeferencer plugin (Raster -> Georeferencer), add the image to the Georeferencer and follow along to add tie points based on the OSM map.
3. Once the Georeferenced image is added to the map, select the streetcars polyline layer from the PostGIS DB and add it to the map.
4. Start an [editor session](https://docs.qgis.org/3.4/en/docs/user_manual/working_with_vector/editing_geometry_attributes.html) on the streetcars layer and begin tracing the streetcar lines.
5. When you are finished tracing right click to end the editing session, add in an attribute for the description of the route.
6. As you save, edits they should show up in the [demo web-app](https://secure-cliffs-69814.herokuapp.com/)
7. When you are done, stop the editing session.

### Guidelines for Digitizing Streetcar routes
- Try to only add features at 1:1000 scale - this keeps the level of detail consistent.  Set the map scale in QGIS by clicking the arrow next to `Scale` in the lower right status bar of the QGIS window.
- Break each line at an intersection to help with the routing analysis in the next stages of the project.
- Save often.

## Code
- Repo for Leaflet, Node, Express App: https://github.com/jondandois/leaflet-express-tutorial
- Deployed Leaflet, Node, Express app: https://secure-cliffs-69814.herokuapp.com/

## Mapping Progress
[See here for mapping progress](MAPPING_PROGRESS.md).

## Next steps

### Clean up / QC
- Georeference the `Outline and Index` map sheet, create a new `atlas_index` polygon table, and digitize each sheet outline.
- Visually compare the digitized street car lines with the individual sheets and make any adjustments, corrections, additions, deletions.

### Validate Topology
- ...


### Routing
- Do routing
- Add POIs and photos

### Convert front-end to an Angular app
- https://devcenter.heroku.com/articles/mean-apps-restful-api
