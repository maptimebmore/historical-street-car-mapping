# MaptimeBmore Historical Streetcar Mapping project
This README provides a guide for the MaptimeBmore Historical Streetcar Mapping project. The goal of the project is to digitize streetcar routes from the 1896 Bromley atlas of Baltimore City. The map sheets are obtained from the Johns Hopkins Sheridan Library system here: [Atlas of the City of Baltimore Maryland](https://jscholarship.library.jhu.edu/handle/1774.2/35300).

## View the map here!
https://maptimebmore.herokuapp.com/

## Tutorial for creating the Leaflet Web Map
[Following along here on the steps needed for creating the web map](docs/WEBMAP_TUTORIAL.md)

## Setup

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
- Deployed Leaflet, Node, Express app: https://maptimebmore.herokuapp.com/

## Mapping Progress
[See here for mapping progress](docs/MAPPING_PROGRESS.md).

## Next steps

### Clean up / QC
- Georeference the `Outline and Index` map sheet, create a new `atlas_index` polygon table, and digitize each sheet outline.
- Visually compare the digitized street car lines with the individual sheets and make any adjustments, corrections, additions, deletions.

### Validate Topology
- Topology refers to the relationships between shapes. By setting topology rules and applying topology validation, we can make sure that features on the streetcar network are correctly mapped.  For example, we need streetcar lines to touch and connect at each end.  Also, when two streetcar lines cross, we need to make sure there is a node or vertex at the intersection to help us with routing - this is because the routing tool will use these vertices to know when to make a turn or change tracks.
- We are going to use the (Geometry Checker Plugin)[https://docs.qgis.org/3.4/en/docs/user_manual/plugins/plugins_geometry_checker.html] in QGIS to help build out the topology rules.
- *Note:* The Geometry Checker plugin seems a bit buggy and causes QGIS to crash a lot.
1. Go to Plugins > Manage and Install Plugins and enable the `Geometry Checker` plugin.
2. Begin a Geometry Checker session: Vector > Check Geometries and Setup the geometry check for the `streetcars` layer.
    1. Select `streetcars` as the only input vector layer.
    2. Under `Geometry validity` check all available validators: `Self intersections`, `Duplicate nodes`, and `Self contacts`.
    3. Under `Geometry properties` check `Lines must not have dangles`.
    4. Under `Topology checks` check `Lines must not intersect any other lines`.
3. Set the `Output vector layers` to `Create new layers` as a new GeoPackage (we want to manually edit our features and not have it done automatically).
4. Click `Run` to create the validated geometry dataset.
5. This will take a few minutes and will then show a `Results` tab showing all the errors that were found.
6. Click `Export` and export the error report to a new GeoPackage `streetcars-errors`. We are going to manually update our `streetcars` table instead of using the interactive editor.

### Correcting topology errors
1. Load the `streetcars-errors` point layer into QGIS.
2. Add a new string field to the `streetcar-errors` point layer called `resolution`, we are going to use this attribute table to track our edits.
3. We are going to use 2 values go through the topology errors: `resolved` and `exception`. Setup a symbology for the errors point layer with 3 values for the field `resolution`: null or blank = `unresolved`, `resolved`, and `exception`. This will help us visually inspect each error.
4. Open the attribute table of the errors layer, and set it to `Show Selected Features`, this will make it easier to edit each error.
5. Navigate on the map to an error, it might help to start at one end of a streetcar route.
6. There will be a `dangle` error at the trailing end of each route, mark these as an `exception` since they mark the end of the line in our dataset.
7. When there are two dangles where the same streetcar line did not connect but should: select the streetcars layer, select one of the lines, select the `Vertex Tool`, move the vertex so that it snaps to the other vertex, then select both line features and click `Merge Selected Features` and pick the correct atributes to merge. Mark the dangles as `resolved`.
8. It might not always make sense to merge to streetcar lines, even if the route is the same.  For example, if a route changes to a different street, it will be useful to keep it as two separate lines.

### Routing
- PG Routing
- Assume
- Add POIs and photos

### Data improvements
- Update with double tracking, and try to make assumptions about route direction.
- Add better street / block designations to each segment.