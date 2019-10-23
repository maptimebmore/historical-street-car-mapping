# Creating the WebApp
Follow the steps below to create basic node application that serves up a Leaflet map and communicates with a Postgres database to show the streetcar layers we digitized.
The tutorial is loosely based on [this tutorial from MDN](https://developer.mozilla.org/en-US/docs/Learn/Server-side/Express_Nodejs/skeleton_website) for getting the express app started. Then we will add some additional features for our Leaflet map and postgis routes.

## Tutorial Steps:
- [Step 0: Get your environment set up](#step-0-get-your-environment-set-up)
- [Step 1: Setting up the basic express app](#step-1-setting-up-the-basic-express-app)
- [Step 2: Setting up the backend DB](#step-2-setting-up-the-backend-DB)
- [Step 3: Connecting the Express API to the DB](#step-3-connecting-the-Express-API-to-the-DB)
- [Step 4: Styling the map](#step-4-styling-the-map)

### Step 0: Get your environment set up
#### Online accounts and config
1. Create a free [Heroku](https://www.heroku.com/) account.
1. Create a new app in Heroku, from the Heroku browser dashboard.
    - Give it a fun name, this will be the name of your public webpage at `https://<app-name>.herokuapps.com`
    - That is all for now.  We will come back to this later to add a db.
1. Create a new github repo for a node app (make sure to select `Add .gitignore: Node`), if you don't have github account you will need to sign up for that too.

#### Install required software
1. Have [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) installed on your computer. If you are on a Windows PC, we will use the Windows `Command Prompt` once Git is installed. 
1. A code editor of your choice. I use [VS Code](https://code.visualstudio.com/), but anything is good.
1. A SQL client, [PGAdmin](https://www.pgadmin.org/download/) is a good choice here.
1. Install latest versions of [Node and npm](https://nodejs.org/en/) (they will come bundled together)
1. Install the [Heroku CLI](https://devcenter.heroku.com/articles/getting-started-with-nodejs?singlepage=true#set-up) and `heroku login` at your command prompt following the instructions.
    - NOTE: I had some issues with doing this in `git bash`, others have recommended using the Windows command prompt to perform `heroku login`, that worked for me too.
    - NOTE: Stop at the section `Prepare the app`, that is where we will insert our own app.

#### Initialize the heroku app with your repo
1. `git clone` the repo you created above to your local machine
1. `cd` into the repo directory 
1. Add the `heroku` remote to your repo: `heroku git:remote -a <app-name>`
    - You will use the name of your heroku app here, not the github repo. 
    - This will create a remote destination in your github repo for your code to be deployed to heroku.
1. Now we will create a generic `node` `express` app:
1. Run `npm init` and follow the defaults.
1. Add `ExpressJS`: `npm install express --save`
1. Create a new file `index.js` and add in this basic express `Hello World` app code:
    ```JS
    // <app-root>/index.js
    let express = require('express');
    let app = express();
    app.get('/', function (req, res) {
        res.send('Hello World! 👋🌎');
    });

    let port = process.env.PORT;
    if (port == null || port == "") { port = 8000; }
    app.listen(port, function () {
        console.log(`Example app listening on port ${port}!`);
    });
    ```

1. Tell heroku we are using nodejs: `heroku buildpacks:set heroku/nodejs`
1. Deploy your app:
    ```SH
    git add .
    git commit -am "getting started"
    git push heroku master
    git push
    ```
1. Use `heroku open` to load up your app!
1. That's all for `Step 0`. In `Step 1` we will set up the barebones [ExpressJS](https://expressjs.com/) application with routes.

### Step 1: Setting up the basic express app

#### Getting the Express Generator boilerplate up and running
1. Install [Express Generator](https://expressjs.com/en/starter/generator.html) `npm install -g express-generator`, we will use this to generate the skeleton app.
1. Build the Express skeleton app using the `pug` view engine. From your repo's root directory, run `express --view=pug`, and follow instructions to install Express.
    - This creates a new express boilerplate application using the [Pug Template Engine](https://pugjs.org/api/getting-started.html)
    - You will get a warning that there are already files present, that is okay, enter `Y` to continue
    - When you are done notice that this added several folders (`bin`, `public`, `routes`, `views`) and the new entry point `app.js`
1. Run `npm start` to see what this new app can do. By default the app will be running at `http://localhost:3000`
    - Check out this ExpressJS tutorial from MDN for more on [Express and Pug](https://developer.mozilla.org/en-US/docs/Learn/Server-side/Express_Nodejs/skeleton_website)
    - The `express-generator` adds a `/users` route to our app by default, take a look at that briefly in the browser at `http://localhost:3000/users` and in `app.js`, and `routes/users.js` to see the basics of how another "route" or page is displayed.  We are going to use that format to create an `/api` route to make database requests.
    - You may need to install additional node packages: npm install package_name
1. Stop the app by hitting `Ctrl + C` or `Ctrl + Z` in your console and let's do some more housekeeping.
    - Remove `index.js`, it is now replaced with `app.js`.
    - In `app.js` remove all the lines that reference the `users` route (roughly Lines 8 and 23)
    - Remove the `users.js` file from the `routes` folder.
1. At any time you can commit your work and push it to heroku to see the changes live in your app. Follow the `git` commands above from Step 0.

So far, most of our work has been in the console, using CLI (command line interface) operations to get the app up and running and to test deploying to Heroku.  In this section, we are going to dive into the HTML, CSS, and JS to get some content on the page. But first, we have one last set of configuration to make our lives easier.  We are going to install [Nodemon](https://nodemon.io/) which is a utility that will reload the node server if file changes are detected. You still need to refresh the browser page to see code changes, but at least this way you don't have to start and stop the node server.
1. Install, configure, and run `nodemon`
    - Install nodemon `npm install -g nodemon`
    - Add a `devstart` to package.json under `scripts` with your _repo name_
        - `"devstart": "SET DEBUG=historical-street-car-mapping:* & nodemon ./bin/www"`
    - Load and test app by running `npm run devstart`
    - Navigate to `http://localhost:3000`
    - Change something in the code, for example the value for `title` in `routes/index.js`, then save. Notice in the terminal that nodemon restarts due to the changes.  Now, if you refresh your browser window, the changes are live!

#### Adding a basic Leaflet layout
1. Now, instead of that `Welcome to Express landing` page, lets add our Leaflet map. In `routes/index.js` change the of title to something you like.
1. On our `views/layout.pug`, add a few basic elements that we are going to build upon with other layouts.  Your `views/layout.pug` should look like this, change the value of the href to your repo, of course!
    ```JS
    // <app-root>/views/layout.pug
    doctype html
    html
    head
        link(rel='favicon', sizes='64x64', href='favicon.ico')
        meta(name="viewport", content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no")

    block head
        title= title
        link(rel='stylesheet', href='/stylesheets/style.css')
    body
        #main.container
            #header
                p To learn more about this project:
                a(href="https://github.com/maptimebmore/historical-street-car-mapping") MaptimeBmore Historical Streetcar Mapping
            block content
    ```
1. Let's unpack what is going on:
    -  Views simply represent different HTML pages, or elements of HTML on a page. When a request is made for a page at a route, Express will locate the views associated with that route, then render the Pug view template with any additional data and send it to the browser as HTML for display in the browser. Pug provides a shorthand for us to write clean, easy to read code that will be compiled into HTML.
    - The first few lines of the `layout.pug` simply create a default HTML page.
    - The next `link` tags shows the little icon on a browser tab.  The `meta` tag helps keep the map fullscreen on different devices.
    - The `block head` section creates a block named head where we can add content to the html page.  Now, we are only making a page title and adding a style sheet. In the next layout, we will add more content.  This keeps the layout head light in case we want to include different content in each view, which we will do.  We are also calling for our own style.css, which is site specific style code.
    - The `body` section has a few different things going on.
        - First, we create a new global div container with the id of `main` and the class `container`. `#` means create a new div with the id of the word that follows, and pairing that with the `.container` tells Pug to also add the class `container` to the new div.
        - Next, inside that div (notice the indents) we have two more sibling divs, a header and a `block content`.  The `header` we are going to keep light, but the `block content` is where we want all our magic to go.
1. Now, change your `views/index.pug` to include a `div` for our map and call a javascript file that will contain our leaflet code:
    ```JS
    // <app-root>/views/index.pug
    extends layout

    block append head
        link(
            rel='stylesheet',
            href="https://unpkg.com/leaflet@1.5.1/dist/leaflet.css",
            integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
            crossorigin=""
        )
        script(
            src="https://unpkg.com/leaflet@1.5.1/dist/leaflet.js",
            integrity="sha512-GffPMF3RvMeYyc1LWMHtK8EbPv0iNZ8/oTtHPx9/cc2ILxQ+u905qIwdpULaqDkyBKgOaB57QTMg7ztg8Jm2Og=="
            crossorigin=""
        )

    block content
        #map
        script(src="/javascripts/map.js")
    ```
    - In `index.pug`, `extends layout` means that this view will add to what is in the `layout.pug` view, and the content of both will be rendered.
    - The `block append head` content means that the next section is going to be added to the `head` block from `layout`.
    - The `link` and `script` lines create the necessary `link` and `script` tags to include Leaflet in our app. These will compile as defined at [Leaflet](https://leafletjs.com/).
    - `block content` replaces whatever other block was called `block content` in `layout` with a new `div` tag with the id `map` and a new `script` tag requesting the `javascripts/map.js` file.
1. Reloading the page now should show our header, but there is a console error that `map.js` cannot be found, which makes sense as we did not create it yet.
1. Let's add some styles to help our layout a bit.  Add the following to `public/stylesheets/style.css`.  This uses CSS Grid to align our header and our map together, and makes the map fill the page after the header.
    ```CSS
    /* <app-root>/public/stylesheets/style.css*/
    body {
        padding: 50px;
        font: 14px "Lucida Grande", Helvetica, Arial, sans-serif;
    }

    a {
        color: #00B7FF;
    }

    html,
    body,
    #main {
        height: 100%;
        width: 100%;
        margin: 0;
        padding: 0;
    }
    .container {
        display: grid;
        grid-template-rows: 2rem auto;
    }
    #map {
        height: 100%;
        width: 100%;
    }

    #header p {
        margin: 0
    }
    ```
1. Finally, lets work on that Leaflet javascript. Create the file, `public/javascripts/map.js` and add the following:
    ```JS
    // <app-root>/public/javascripts/map.js

    // start leaflet map
    let map = L.map('map', {
        center: [39.29564, -76.60689], //coordinates for Baltimore
        zoom: 13,
        minZoom: 4,
        maxZoom: 19
    });

    // add basemap
    L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
    ```
1. This is standard for any new Leaflet map.  The first block creates a new instance of Leaflet.map, on the HTML element with the id `map` and then Initializes it with some basic location data for latitude, longitude, and zoom.  The next section initializes a new tile map layer as the basemap and adds it to our map with `.addTo(map)`.  If it is bit confusing that there are three things here named `map`, you can change some of them around.  For the most part, once this is set up, you will only be using the map created by `let map =`, so it might not be an issue.
1. Saving and reloading your page shows a nice header and a shiny Leaflet map.  Congratulations!
1. If you don't like the basemap, pick another one from the [Leaflet Providers Demo](https://leaflet-extras.github.io/leaflet-providers/preview/).  Note that some of these require an API key.
1. Let's commit and push this to heroku to see our lovely map in action:
    ```SH
    git add .
    git commit -am "I made a map"
    git push heroku master
    git push
    ```
1. Congratulations


### Step 2: Setting up the backend DB

#### Adding Postgres to your Heroku app
1. Go to https://dashboard.heroku.com and navigate to your app's overview page.
1. Click on the `Resources` tab and under `Add-ons` type in `Postgres`, select `Heroku Postgres` when it appears.
1. Select the Hobby Dev Free tier and click Provision.
1. Click on the `Heroku Postgres` resource and it will navigate you to the datastore's config page.
1. Under Settings, select Database Credentials.  We will need this to connect to the DB in our app, in the DB client, and in QGIS. Keep this window open.
1. Let's assume you are using PGAdmin to connect to the database. In PGAdmin, right click on Servers > Create > Server.
1. Add a 'Name', like 'Heroku Postgres', this just identifies the connection in your list of connections.
1. Go to the Connection tab.
1. Enter the information from the Heroku Database Credentials window here.  "Maintenance database" is the Heroku database name.
1. Click the SSL tab and set "SSL Mode = Require".
1. Click the Advanced tab, for DB Restriction, enter your Heroku database name.
1. Hit Save, yay!  You connected!

#### Adding data to Postgres
1. Now, let's add some data. In the PGAdmin Browser, expand until you get to your database, it's the one with the goofy name. Right click and select Query Tool.
1. Now we are going to perform several SQL operations from the file `/docs/db_setup.sql`, including creating the postgis extension, removing all the extra projections, and adding our tables. That sql file also includes scripts to create triggers to keep a history of data edits. That isn't really necessary for this tutorial, but might be nice to see how it works. For now though, the following is all you really need:
    ```SQL
    -- add postgis extension
    CREATE extension postgis;
    -- ###############################

    --remove extra projections to save space
    DELETE FROM spatial_ref_sys
        WHERE
            srid != 2248 AND
            srid != 4326 AND
            srid != 3857;
    -- ###############################

    -- create our main table
    CREATE TABLE streetcars (
        ID serial primary key,
        detail text,
        geom geometry(LINESTRING,2248),
        editor varchar(25)
    );
    -- ###############################
    ```
1. The first block enables the PostGIS extension on our Postgres database. This enables the spatial data types and the spatial commands we are going to use later to get data.
1. The second block removes all but a handful of projections. Since the Heroku Hobby Dev free tier counts each DB row, we need to make every one count. In this case we are just keeping 2248 (Maryland NAD83 State Plane Feet), 4326 (Geographic WGS84), 3857 (WGS84 Web Mercator).
1. In the last block we are creating the streetcars table with a few basic columns.
1. Execute this by hitting F5. It should work okay and then you can see the new table in the Browser.
1. Clear out the Query window and copy in the contents from the file `docs/streetcars_export_20191021.sql`.  This contains a script-ready dump of the current streetcars table. Hit F5 to execute, hopefully it works okay.
1. Clearing out the query window and selecting all rows `SELECT * FROM streetcars;` should show you all the new rows you imported!

#### Test out the data in QGIS
1. Finally, let's connect in QGIS to confirm everything worked.
1. Open QGIS, expand the Browser, right click on PostGIS and select New Connection.
1. Enter your Heroku Database credentials, Name is just a name for inside QGIS, leave Service blank, Host is Host, leave Port the same, Database is database, set SSL mode to 'require', for Authentication, select Basic and enter the Heroku DB username and password.  For our testing, I think it is okay to store the credentials locally, but this would not be secure for anything important.
1. Test the connection, it should work okay. Then hit OK.
1. Expand the connection until you get to your streetcars table and add it to the map.
1. Congratulations!  You now have a remote GIS database running!

In the next steps we will set up connectors to the database in Express to show the data on our Leaflet map.

### Step 3: Connecting the Express API to the DB
Almost done. In this step we are going to add a new route to our express app to query the postgres database and then send data to the map. When we do this we are creating a buffer between the Leaflet map in the user's browser and the database. The buffer is our node/express server that accepts requests from the webmap, makes its own secure request to the database, then returns the response safely back to the browser. This way, the browser never knows that the database exists and the secrets that we use to connect to the database are secure. The new route will be at `/api/streetcars` and later we will tell leaflet to fetch data from that URL and then render it on the map.

#### Get the basic route setup
1. Let's start by registering the new route in our `app.js` file. First we include the handler for our new route just like the indexRouter, then we define what to do when the URL is visited:
    ```JS
    // <app-root>/app.js
    //...
    // start here, this should be around Line 7
    var indexRouter = require('./routes/index');
    // add this streetcarsRouter line in right after the indexRouter line.
    var streetcarsRouter = require('./routes/api/streetcars');

    //... more stuff about view engine setup and other lines that are "express middleware"

    app.use('/', indexRouter);
    // then down here, around Line 22-23, add in this line after the app.use('/'...
    app.use('/api/streetcars', streetcarsRouter);
    //...
    ```
1. The first line we add creates the variable for our route controller, this is where Express is going to send any requests to the new route. The second line we create tells Express which URLs are valid for our app. They are processed in order. First, anything to `/` or the main app URL is going to go to our index route and view.  Then, requests made to `/api/streetcars` will be forwarded to the steetcars Router. After that, nothing else is handled and a 404 will be returned.
1. So right now your app is probably crashing, it is going to throw an error that the module `./routes/api/streetcars` cannot be found. So let's make it.
1. Under `routes`, make a new folder `api`.  Inside the `api` folder, make a new file `streetcars.js`
1. Add the following to the `streetcars.js` file:
    ```JS
    var express = require('express');
    var router = express.Router();

    /* GET streetcar data */
    router.get('/', function(req, res) {
        res.status(200).json({ message: "I'm the streetcars route! 🚃 🚃 🚃 " });
    });

    module.exports = router;
    ```
1. The first 2 lines gather our express functions. The main function called is the `router.get` this tells express that if it receives an HTTP GET request to `/api/steetcars`, keep processing it. No other HTTP request types to that URL will be processed and 404 will be returned.
1. For now, we just have the route return a status code of 200 and a short JSON message. Test it out to make sure everything works.

#### Configure the route to communicate with postgres db
Now we will configure the app to communicate with the database, make a SQL request, then return the results.
1. Stop the server, `Ctrl+C` or `Ctrl+Z` in whatever terminal you are using.
1. Install two npm libraries, `dotenv` and `pg`: `npm install --save dotenv pg`.
    - `dotenv` is a library that allows us to read from local environment `.env` files to read app secrets.
    - `pg` installs the [node-postgres](https://node-postgres.com/features/pooling) library with tools for communicating with a postgres DB.
1. Create a new file in your app root called `.env`. Windows might hide this, but VS code will show it.
    - NOTE: if you created your github repo as a node app, there should be a `.gitignore` file which is set by default to ignore `.env` files, thereby not committing them to Github.  That is a good thing, you don't want to publish your DB secrets to the world!
    - When you create the `.env` file you should notice that git does not see it is there when you enter `git status` from the command line.
1. In your `.env`, add in the value of your `DATABASE_URL` from the Heroku database credentials page (the value URI)
    ```SH
    DATABASE_URL=postgres://.......
    ```
1. Back in `streetcars.js`, add in this connection information, it should look like this:
    ```JS
    // <app-root>/routes/api/streetcars.js
    var express = require('express');
    var router = express.Router();

    /* PostgreSQL and PostGIS module and connection setup */
    require('dotenv').config();
    var database_url = process.env.DATABASE_URL;
    const Pool = require('pg').Pool;
    const pool = new Pool({
        connectionString: database_url,
        ssl: true
    });

    /* GET streetcar data */
    router.get('/', function(req, res) {
        res.status(200).json({ message: "I'm the streetcars route! 🚃 🚃 🚃 " });
    });

    module.exports = router;
    ```
1. We only added a few lines, but a lot is going on:
    - `require('dotenv').config();` loads what is in the `.env` file as environment variables.
    - `var database_url = process.env.DATABASE_URL;` grabs the DATABASE_URL variable from our `.env` file.
    - The next few lines with `Pool` create a connection to the Postgres database using a "pool" of connections that improves performance when communicating with the database. For more on what the `pg` library is doing, check out the docs here: [node-postgres](https://node-postgres.com/features/pooling)
1. We haven't made any requests to the db yet, so lets do that! Keep editing `streetcars.js` and add the database query inside the `.get`, the file should look like this:
    ```JS
    // <app-root>/routes/api/streetcars.js
    var express = require('express');
    var router = express.Router();

    /* PostgreSQL and PostGIS module and connection setup */
    require('dotenv').config();
    var database_url = process.env.DATABASE_URL;
    const Pool = require('pg').Pool;
    const pool = new Pool({
        connectionString: database_url,
        ssl: true
    });

    /* GET streetcar data */
    router.get('/', function(req, res) {
        var featureClass = 'streetcars';
        var query = `
            SELECT jsonb_build_object(
                'type',     'FeatureCollection',
                'features', jsonb_agg(features.feature)
            ) as dataset
            FROM (
            SELECT jsonb_build_object(
                'type',       'Feature',
                'id',         id,
                'geometry',   ST_AsGeoJSON(ST_Transform(geom, 4326))::jsonb,
                'properties', to_jsonb(inputs) - 'geom'
            ) AS feature
            FROM (SELECT * FROM public.${featureClass}) inputs) features
        `;
        pool.query(query, (err, results) => {
            if (err) {
                let status = 500;
                res.locals.message = "Something went wrong"
                res.locals.error = err;
                res.locals.error.status = status;
                return res.status(status).json({"message": "There was a problem communicating with the server"});
            }
            res.status(200).json(results.rows[0]['dataset'])
        });
    });

    module.exports = router;
    ```
1. Save and reload the `/api/streetcars` route.  If all goes well, you should get a big dump of GeoJSON from the database.  Woohoo! If not, you probably got an error. Try inserting a `console.log(err)` right above `let status = 500`.  This will print the full error message to your terminal window. There might be a typo.
1. So what is happening here?
    - In the `var query = ` block we are creating one big SQL string that is going to be passed to the database. A template string is used to show how the only thing unique about this query for our database is the featureClass name, everything else would be more or less standard if you wanted to reuse this for another PostGIS table. In fact, you can also change the value of `featureClass` and see how the query handles an error if it cannot find the table.
    - The query string is passed into the `pool.query`, this sends the query to the database just as if you had run it inside a SQL client.
    - If the query comes back with an error `err` we catch that and send back some error messages.
    - Otherwise, we grab the piece of data from the results called `dataset` and send it back out to express to send it back to whichever app made the request to `/api/streetcars`.
1. Congratulations! You made an API that talks to your database and returns GeoJSON. Now let's do something with that.

#### Connect the route to the map and draw the streetcar lines
Without getting too deep into the weeds, for the next step we have to tell Javascript to do something that is going to take some time, then only when that thing is done, do something with the result. We don't want Javascript to try to run the code on the result until the result has arrived. In our case we need to make a request to our API for the GeoJSON, then when that data comes back, we need to style it and add it to the map.  There are many ways this can be done, we are going to use JQuery because it is easy and we can move on with making a map. This Leaflet tutorial from [MaptimeBoston](https://maptimeboston.github.io/leaflet-intro/) has some references for that as well.

1. Include JQuery in the `index.pug` view after the Leaflet script tag, your file will look like this:
    ```JS
    // <app-root>/views/index.pug
    extends layout

    block append head
    link(
        rel='stylesheet',
        href="https://unpkg.com/leaflet@1.5.1/dist/leaflet.css",
        integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
        crossorigin=""
    )
    script(
        src="https://unpkg.com/leaflet@1.5.1/dist/leaflet.js",
        integrity="sha512-GffPMF3RvMeYyc1LWMHtK8EbPv0iNZ8/oTtHPx9/cc2ILxQ+u905qIwdpULaqDkyBKgOaB57QTMg7ztg8Jm2Og=="
        crossorigin=""
    )
    script(
        src="https://code.jquery.com/jquery-3.4.1.min.js"
        integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="
        crossorigin="anonymous"
    )

    block content
        #map
        script(src="/javascripts/map.js")
    ```
1. Add the following at the bottom of `map.js` to use the JQuery `$.geoJSON` function to request data from our `/api/streetcars` route, then pass that into Leaflet and add it to the map:
    ```JS
    // <app-root>/public/javascripts/map.js
    // fetch the data from our API and render it on the map:
    $.getJSON('/api/streetcars', function(data) {
        L.geoJson(data).addTo(map);
    });
    ```
1. Reload the map at the home page, boom! You should have some pretty lines. Congratulations! We're done here, let's pack it up.


### Step 4: Styling the map
From here there is a lot you can do, just explore the options over at https://leafletjs.com/. To wrap up this tutorial we are going to work on styling our lines and adding some basic popups.

1. Back in `map.js`, let's add some different style to the lines, we are going to add to the block inside the `$.getJSON('/api/streetcars'...`, remember, all that code runs after the geoJSON has loaded:
    ```JS
    // <app-root>/public/javascripts/map.js
    $.getJSON('/api/streetcars', function(data) {
        var geojson = L.geoJson(data, {
            style: {
                color: "#354ae9",
                opacity: 0.4,
                weight: 3
            }
        });
        geojson.addTo(map);
    });
    ```
1. Every line will get a blue color and some opacity. You can also set attribute specific styles by passing a function to `style`, as described here: https://leafletjs.com/examples/geojson/. We also set the result of `L.geoJson` to its own variable so we can do more with that layer later.
1. Finally, let's add some popups to our features. Again, we are going to keep this simple, add this right after the `geojson.addTo(map);` line:
    ```JS
    // <app-root>/public/javascripts/map.js
    geojson.bindPopup(function(event){
        var props = event.feature.properties;
        var label = `
            <b>Detail:</b> ${props.detail}
            </br>
            <b>Line ID:</b> ${props.id}
            `;
        return label;
    });
    ```
1. Here, bindPopup is taking a new function that will be run on every `event` where you click on a line. The function picks apart the attributes (the properties) on the geojson feature and then returns some simple HTML.  Since it is just HTML, you could add a lot of detail and complexity to the popup, depending on your data.
1. Okay, that is really it.  Time to deploy to Heroku to see it all in action.
    ```SH
    git add .
    git commit -am "STEP 4: I've come so far!"
    git push heroku master
    git push
    ```
1. Use `heroku open` to load your map.
1. One thing you might have noticed, if we didn't commit our `.env` file, then how does Heroku know how to connect to the database?  The variable `DATABASE_URL` is also set by Heroku for the primary DB we attached to our app, so by telling `/api/streetcars.js` to use `process.env.DATABASE_URL` it is able to grab the correct value from within the Heroku environment. Magic 🧙‍, https://devcenter.heroku.com/articles/heroku-postgresql#designating-a-primary-database.
1. Congratulations on getting through the whole thing.  I hope you learned a few things along the way.

### Some additional resources for your reading pleasure.
- [MDN Express-NodeJS Skeleton website](https://developer.mozilla.org/en-US/docs/Learn/Server-side/Express_Nodejs/skeleton_website)
    - This is a great complete tutorial for server-side web-dev with NodeJS and Express.
- [Leaflet with PostGIS, NodeJS, and Express - with Duspviz](http://duspviz.mit.edu/web-map-workshop/leaflet_nodejs_postgis/)
    - Another good tutorial that I based our app off of.
- [A Leaflet Tutorial from MaptimeBoston](https://maptimeboston.github.io/leaflet-intro/)
- [Full Stack Vue.js, Express & MongoDB [1] - Express API - Traversy Media
](https://www.youtube.com/watch?v=j55fHUJqtyw)
    - This guy does a great job of breaking down details, this is for a Vue.JS app with a MongoDB, but a lot of same priniples apply.
- [Leaflet with a GeoJSON layer from bl.ocks.org](http://bl.ocks.org/hpfast/5017e08b6c27b5abd287c2cf21c0c533)
    - This is a different way to fetch the GeoJSON using the more current async/await functionality of modern JS.  This approach also creates several nice functions and patterns that can be reused for getting lots of data and rendering it differently.
