// <app-root>/index.js
let express = require('express');
let app = express();
app.get('/', function (req, res) {
    res.send('Hello World! 👋🌎');
});

let port = process.env.PORT;
if (port == null || port == "") { 
    port = 8000; 
}
app.listen(port, function () {
    console.log(`Example app listening on port ${port}!`);
});