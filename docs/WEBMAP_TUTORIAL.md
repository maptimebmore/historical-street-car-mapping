# Creating the WebApp
Follow the steps below to create basic node application that serves up a Leaflet map and communicates with a Postgres database to show streetcar layers.
The tutorial is loosely based on [this tutorial from MDN](https://developer.mozilla.org/en-US/docs/Learn/Server-side/Express_Nodejs/skeleton_website) for getting the express app started. Then we will add some additional features for our Leaflet map and postgis routes. Each commit of the tutorial will be a specific step in the process.

## Tutorial Steps Draft:

### Step 0: Get your environment set up
#### Online accounts and config
1. Create a free [Heroku](https://www.heroku.com/) account.
1. Create a new app in Heroku, from the Heroku browser dashboard.
    - give it a fun name, this will be the name of your public webpage at `https://<app-name>.herokuapps.com`
    - That is all for now.  We will come back to this later to add a db.
1. Create a new github repo, if you don't have github you will need to sign up for an account too. 

#### Install required software
1. [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) installed on your computer. If you are on a Windows PC, we will be using the program `Git Bash`.
1. A code editor of your choice. I use [VS Code](https://code.visualstudio.com/), but anything is good.
1. A SQL client, [PGAdmin](https://www.pgadmin.org/download/) is a good choice here. 
1. Install latest versions of [Node and npm](https://nodejs.org/en/) (they will come bunlded together)
1. Install the [Heroku CLI](https://devcenter.heroku.com/articles/getting-started-with-nodejs?singlepage=true#set-up) and `heroku login` at your command prompt (e.g, `git bash`) following the instructions. 
    - NOTE: I had some issues with doing this in `git bash`, others have reccomended using the Windows command prompt to perform `heroku login`, that worked for me too.
    - NOTE: Stop at the section `Prepare the app`, that is where we will insert our own app. 

#### Initialize the heroku app with your repo
1. `git clone` the repo you created above to your local machine
1. Add the `heroku` remote to your repo: `heroku git:remote -a <app-name>`
    - This will create a remote destination in your heroku app for your code to be deployed to. 
1. Now we will create a generic `node` `express` app:
1. Run `npm  init` and follow the defaults.
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

### DRAFT other steps

2. Setup Backend
    1. Setup new heroku node app, add postrgres DB
    1. Connect to postgres in sql client
    1. Run the db_setup.sql script to populate the schema (do this one block at a time)
    1. Import the streetcar dump file to populate with data


3. Setup Frontend
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


