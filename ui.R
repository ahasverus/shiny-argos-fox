do.call(library, list(package = 'shiny', character.only = TRUE))
do.call(library, list(package = 'leaflet', character.only = TRUE))

library(shiny)
library(leaflet)

LOCS <- readRDS('localisations_onedays.rds')
dens <- readRDS('coords_dens.rds')

ui <- bootstrapPage(

    tags$style(type = "text/css", "html, body {width:100%;height:100%} .pad {margin-top: 15; margin-bottom: 15}"),

    leafletOutput(outputId = "map", width = "100%", height = "100%"),

    absolutePanel(id = 'panel', style = 'background-color: #fff; padding: 35px; opacity: 0.75',
                  top = 10, right = 10, bottom = 10,

                  sliderInput(inputId = "range", label = "Date", min(as.Date(LOCS$dateloc)), max(as.Date(LOCS$dateloc)),
                              value = range(as.Date(LOCS$dateloc)), step = 1),

                  HTML('<hr /><div class="pad">'),

                  selectInput(inputId = "cc", label = "Fox identifiant", sort(unique(as.character(LOCS[, "noid"])))),

                  HTML('</div><hr /><div class="pad">'),

                  checkboxInput("localisations", "Show localisations", TRUE),
                  checkboxInput("trajectory", "Show trajectory", TRUE),
                  checkboxInput("dens", "Show fox dens", TRUE),
                  checkboxInput("camp", "Show camps", TRUE),

                  HTML('</div>')
    )
)
