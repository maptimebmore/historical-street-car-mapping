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

// fetch the data from our API and render it on the map:
$.getJSON('/api/streetcars', function(data) {
  var geojson = L.geoJson(data, {
      style: {
          color: "#354ae9",
          opacity: 0.3,
          weight: 3
      }
  });
  geojson.addTo(map);

  geojson.bindPopup(function(event){
    var props = event.feature.properties;
    var label = `
      <b>Detail:</b> ${props.detail}
      </br>
      <b>Line ID:</b> ${props.id}
    `;
    return label;
  });
});