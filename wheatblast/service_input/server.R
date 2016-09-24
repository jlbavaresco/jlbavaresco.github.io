


shinyServer(function(input, output, session) {
      
  
  ## gerando os dados com o valor de ip para a seleção do usuário
  
  dados <- reactive ({
    withProgress(message = 'Generating map...', value = 0, {            
      ##executarPorInterface(experiment,input$floweringDate)      
      #dados <- NULL
      #if (startingDate != input$floweringDate){
      #  startingDate <<- input$floweringDate
      #  urlServico <- paste("http://",servidor,"/agroservice/services/experiment/wheatblastinputdate/",
      #                      experiment, "/",2, "/",input$floweringDate,sep = "")
      #  dados <- fromJSON(urlServico)
      #}      
#       if (input$variable == "ip"){
#         recuperaIpCidadesExperimento(experiment)      
#       } else {   
#         recuperaIncidenceCidadesExperimento(experiment)  
#       }
      urlServico <- paste("http://",servidor,"/services/experiment/wheatblastinputdate/",
                          experiment, "/",input$modelVersion, "/",input$floweringDate,sep = "")
      dados <- fromJSON(urlServico)      
      dados
    })
    ##withProgress(message = 'Map successfully generated...', value = 0, {            
    ##  Sys.sleep(1)
    ##})
  })
  


  
  ## Interactive Map ###########################################

  # Create the map
  map <- createLeafletMap(session, "map")
  
  # session$onFlushed is necessary to work around a bug in the Shiny/Leaflet
  # integration; without it, the addCircle commands arrive in the browser
  # before the map is created.
  session$onFlushed(once=TRUE, function() {
    
    paintObs <- observe({ 
            
      
      ## obtendo as coordenadas centrais conforme o conjunto de dados
      coord <- c(mean(dados()[1:nrow(dados()),]$latitude),mean(dados()[1:nrow(dados()),]$longitude))
      ## centralizando dinamicamente conforme o conjunto de dados  
      map$setView(coord[1], coord[2], zoom = 7)      
      # Clear existing circles before drawing
      map$clearShapes()    
      dados <- dados()
      for (i in 1:nrow(dados)){
        linha <- dados[i,]
        if (input$variable == "ip"){
          col <- ifelse(linha$potentialInoculum < 30, '#008000',
                        ifelse(linha$potentialInoculum >= 50,'#ff0000','#ffa500')) 
          tamanho <- linha$ip * 300          
        } else {
          col <- ifelse(linha$incidence > 0, '#ff0000','#008000')      
          tamanho <- ifelse(linha$incidence > 0, (linha$incidence * 120) * numberHeads,7000)   
        }        
        try(
          map$addCircle(
            linha$lat, linha$long,
            tamanho,
            linha$treatment,
            list(stroke=FALSE, fill=TRUE, fillOpacity=0.4),
            list(color = col)
          )
        )        
      }
    })
    
    # TIL this is necessary in order to prevent the observer from
    # attempting to write to the websocket after the session is gone.
    session$onSessionEnded(paintObs$suspend)
  })
  
  # Show a popup at the given location
  showZipcodePopup <- function(treatment, lat, lng) { 
    print(paste("showZipcodePopup treatment:",treatment))
    selected <- dados()[dados()$treatment == treatment,]    
    content <- as.character(tagList(
      tags$h4(paste("Treatment: ",as.integer(selected$treatment))),
      tags$strong(HTML(sprintf("%s",
        paste("City:", selected$city)
      ))), tags$br(),    
      sprintf("Latitude: %s", as.double(selected$latitude)), tags$br(),
      sprintf("Longitude: %s", as.double(selected$longitude)), tags$br(),
      
      #if (input$variable == "ip"){
        sprintf("IP (Potential inoculum): %s", selected$potentialInoculum), tags$br(),
      #} else {
        sprintf("Brusone Incidence: %s", selected$incidence)
      #}            
    ))
    map$showPopup(lat, lng, content, treatment)
  }

  # When map is clicked, show a popup with city info
  clickObs <- observe({    
    map$clearPopups()
    event <- input$map_shape_click    
    if (is.null(event))
      return()        
    isolate({      
      showZipcodePopup(event$id, event$lat, event$lng)
    })
  })
  
  session$onSessionEnded(clickObs$suspend)
  
  
  ## Data Explorer ###########################################
  observe({
    if (is.null(input$goto))
      return()
    isolate({
      map$clearPopups()
      dist <- 0.5
      treatment <- input$goto$treatment
      lat <- input$goto$lat
      lng <- input$goto$lng
      showZipcodePopup(treatment, lat, lng)
      map$fitBounds(lat - dist, lng - dist,
        lat + dist, lng + dist)
    })
  })
  
   output$downloadData <- downloadHandler(
     filename = function() {
       paste('experiment-',experiment,'-data-', Sys.Date(), '.csv', sep='')
     },
     content = function(f) {
       write.table(row.names = F,x=dados(), file=f,quote=FALSE, sep=";")       
     }
   )  
  
output$datatable <- renderDataTable({
      dados() %>%
        filter(

        ) %>%
        mutate(Action = paste('<a class="go-map" href="" data-latitude="', latitude, '" data-longitude="', longitude, '" data-treatment="', treatment, '"><i class="fa fa-crosshairs"></i></a>', sep=""))
}, escape = FALSE)
})
