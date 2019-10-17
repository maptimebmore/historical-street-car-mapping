// start leaflet map
let map = L.map('map', {
  center: [39.29564, -76.60689],
  zoom: 13,
  minZoom: 4,
  maxZoom: 19
});

// add basemap
L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);
