



## coordenadas do parana
centerLat <- -24.5
centerLong <- -50
maxBoundsLat1 <- -22
maxBoundsLat2 <- -27
maxBoundsLong1 <- -46
maxBoundsLong2 <- -54    

shinyUI(navbarPage("Risk Map", id="nav",theme = "bootstrap.css",

  tabPanel("Interactive map",
           
    div(class="outer",
      
      tags$head(
        # Include our custom CSS
        includeCSS("styles.css"),
        includeScript("gomap.js")
      ),
      
      leafletMap("map", width="100%", height="100%",
        initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
        options=list(
          
          ## configurações do recorte e centralização do mapa          

          # lat,long
          center = c(centerLat,centerLong),
          zoom = 7#,
          # lat,long dois minimo
        #  maxBounds = list(list(maxBoundsLat1,maxBoundsLong1), list(maxBoundsLat2,maxBoundsLong2)) # Show PR only  
          
          ## parana
          # lat,long
#           center = c(-24.5,-50),
#           zoom = 7,
#           # lat,long dois minimo
#           maxBounds = list(list(-22,-46), list(-27,-54)) # Show PR only  
          
          ## kentucky
#           # lat,long
#           center = c(37,-84.5),
#           zoom = 7,
#           # lat,long dois minimo
#           maxBounds = list(list(39,-90), list(36,-78)) # Show kentucky only
        )
      ),
      
      absolutePanel(id = "controls",  class = "panel panel-default",fixed = TRUE, draggable = TRUE,
        top = 100, left = "auto", right = 140, bottom = "auto",
        width = 230, height = "auto",              
        
        h2("Data Input"),
        
        dateInput("floweringDate", "Heading date:", value=startingDate)   ,
        selectInput("variable", "Variable:",
                    c("Brusone Incidence" = "incidence","IP (Potential inoculum)" = "ip")),
        selectInput("modelVersion", "Model version:",
                    c("Version 2" = "2","Version 1" = "1")),        
        downloadButton('downloadData', 'Download')
      
      ),
      
      tags$div(id="cite",
        'Data compiled for ', tags$em('IFSUL 2015'), ' by Bavaresco 2015.'
      )
    )
  ),

  tabPanel("Data explorer",
    dataTableOutput("datatable")
  ),
  
  conditionalPanel("false", icon("crosshair"))
))
