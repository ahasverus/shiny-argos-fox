do.call(library, list(package = 'shiny', character.only = TRUE))
do.call(library, list(package = 'leaflet', character.only = TRUE))

LOCS <- readRDS('localisations_onedays.rds')
dens <- readRDS('coords_dens.rds')

server <- function(input, output, session) {




    data_dens <- reactive({

        dens[grep('F', dens[ , 'noden']), ]
    })



    data_camp <- reactive({

        dens[grep('Camp', dens[ , 'noden']), ]
    })



    sel_ids <- reactive({

        sort(unique(as.character(LOCS[which(as.Date(LOCS$dateloc) >= as.Date(input$range[1]) & as.Date(LOCS$dateloc) <= as.Date(input$range[2])), "noid"])))
    })



    data <- reactive({

        LOCS[(as.Date(LOCS$dateloc) >= as.Date(input$range[1]) & as.Date(LOCS$dateloc) <= as.Date(input$range[2])) & as.character(LOCS$noid) == input$cc, ]
    })

    output$map <- renderLeaflet({

        map <- leaflet(LOCS) %>% addTiles() %>%
        fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))
    })



    observe({

        if (nrow(data()) == 0){

            updateSelectInput(session, inputId = 'cc', label = "Fox identifiant", choices = sel_ids(), selected = sel_ids()[1])
            data <- reactive({
                LOCS[(as.Date(LOCS$dateloc) >= as.Date(input$range[1]) & as.Date(LOCS$dateloc) <= as.Date(input$range[2])) & as.character(LOCS$noid) == sel_ids()[1], ]
            })

        } else {

            updateSelectInput(session, inputId = 'cc', label = "Fox identifiant", choices = sel_ids(), selected = input$cc)
        }

        leafletProxy("map", data = data()) %>% clearShapes() %>% clearControls() %>%
        fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))

        if (input$localisations) {

            leafletProxy("map", data = data()) %>% addCircles(~longitude, ~latitude, fillColor = '#e41a1c', radius = ~500, stroke = F, group = 'locs', popup = ~paste('<span style="font-weight: bold; text-align: center">', noid, ': </span>', dateloc))

        } else {

            leafletProxy("map", data = data()) %>% clearGroup("locs")
        }

        if (input$trajectory) {

            leafletProxy("map", data = data()) %>% addPolylines(~longitude, ~latitude, color = 'black', group = 'traj', stroke = T, weight = 1, opacity = 1)

        } else {

            leafletProxy("map", data = data()) %>% clearGroup("traj")
        }

        if (input$dens) {

            leafletProxy("map", data = data_dens()) %>% addCircles(~longitude, ~latitude, group = 'dens', fillColor = '#018571', color = '#018571', opacity = 1, weight = 2, radius = ~500, stroke = T, popup = ~paste('<span style="font-weight: bold; text-align: center">', noden, '</span>'))

        } else {

            leafletProxy("map", data = data()) %>% clearGroup("dens")
        }

        if (input$camp) {

            leafletProxy("map", data = data_camp()) %>% addCircles(~longitude, ~latitude, group = 'camp', fillColor = '#a6611a', color = '#a6611a', opacity = 1, weight = 2, radius = ~500, stroke = T, popup = ~paste('<span style="font-weight: bold; text-align: center">', noden, '</span>'))

        } else {

            leafletProxy("map", data = data()) %>% clearGroup("camp")
        }
    })
}
