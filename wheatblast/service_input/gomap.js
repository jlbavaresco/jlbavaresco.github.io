// When locator icon in datatable is clicked, go to that spot on the map
$(document).on("click", ".go-map", function(e) {
  e.preventDefault();
  $el = $(this);
  var lat = $el.data("latitude");
  var long = $el.data("longitude");
  var treatment = $el.data("treatment");  
  $($("#nav a")[0]).tab("show");
  Shiny.onInputChange("goto", {
    lat: lat,
    lng: long,
    treatment: treatment,
    nonce: Math.random()
  });
});
