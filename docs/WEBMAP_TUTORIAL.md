# Creating the WebApp
Follow the steps below to create basic node application that serves up a Leaflet map and communicates with a Postgres database to show streetcar layers.
The tutorial is loosely based on [this tutorial from MDN](https://developer.mozilla.org/en-US/docs/Learn/Server-side/Express_Nodejs/skeleton_website) for getting the express app started. Then we will add some additional features for our Leaflet map and postgis routes. Each commit of the tutorial will be a specific step in the process.

## Tutorial Steps Draft:
1. Environment
    1. Code editor
    1. sql client
    1. heroku account
2. Setup Backend
    1. Setup new heroku node app, add postrgres DB
    1. Connect to postgres in sql client
    1. Run the db_setup.sql script to populate the schema (do this one block at a time)
    1. Import the streetcar dump file to populate with data
3. Setup Frontend
    1. Install [node and npm](https://nodejs.org/en/) on your machine
    1. Create a new node github repo, `git clone` it locally, and `cd` into it
    1. Install [Express Generator](https://expressjs.com/en/starter/generator.html) `npm install -g express-generator`, we will use this to generate the skeleton app.
    1. Build the Express skeleton app using the `pug` view engine.  The second variable is your app name. `express leaflet-express-tutorial --view=pug`, and follow instructions to install and run
    1. Install nodemon `npm install -g nodemon`
    1. add `devstart` to package.json under `scripts` with your app name
        - `"devstart": "SET DEBUG=leaflet-express-tutorial:* & nodemon ./bin/www"`
    1. load and test app by running `npm run devstart`
    1. ...
    1. ...
    1. make a new route for `streetcars`
    1. create your `.env` file
    1. connect to your Heroku DB with `DATABASE_URL`
    1. add a map (http://duspviz.mit.edu/web-map-workshop/leaflet_nodejs_postgis/)
    1. connect map to API and draw features!


