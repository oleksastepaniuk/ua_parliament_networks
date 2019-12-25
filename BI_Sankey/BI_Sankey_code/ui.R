# import packages
library(shiny)
library(shinydashboard)
library(networkD3)
library(DT)



#############################
####   User interface    ####
#############################


# Header
header <- dashboardHeader(title = "Ukrainian Parliament. BI tool", titleWidth = 550,
                          dropdownMenu(type = "notifications", badgeStatus = NULL,
                                       notificationItem(
                                         text = "(c) Oleksa Stepaniuk 2019",
                                         icon("flask"))
                          )
)


# Sidebar
sidebar <- dashboardSidebar(sidebarMenu(
  menuItem("Big picture", tabName = "big_picture", icon = icon("calculator")),
  menuItem("Factions", tabName = "factions", icon = icon("cogs")),
  menuItem("Radas", tabName = "radas", icon = icon("cogs")),
  menuItem("MPs", tabName = "mps", icon = icon("cogs")),
  menuItem("Repository", icon = icon("file"),
           href = "https://github.com/oleksastepaniuk/ua_parliament_networks",
           badgeLabel = "link", badgeColor = "green"),
  menuItem("Data", icon = icon("file"),
           href = "https://www.kaggle.com/dataset/9b5e80df136eddb01b7e860c448436cfc569a8a92409f9b74fad560bbe41d1e6",
           badgeLabel = "link", badgeColor = "green")
  ))


# Body of the dashboard
body <-   dashboardBody(
  
  # check is sidebar is collapsed
  # source: https://www.r-bloggers.com/three-r-shiny-tricks-to-make-your-shiny-app-shines-23-semi-collapsible-sidebar/
  tags$script("$(document).on('click', '.sidebar-toggle',
              function () {
              Shiny.onInputChange('SideBar_col_react', Math.random())
              });"),
  
  tags$head(tags$style('
                       
                       .main-header .logo {
                          font-family: "Tahoma";
                          font-weight: bold;
                          font-size: 20px;
                       }
                       
                       h1 {
                          font-family: "Tahoma";
                          color: #595959;
                       }

                       h2 {
                          font-family: "Tahoma";
                          color: #595959;
                       }

                       p {
                          font-family: "Tahoma";
                          font-size: 20px;
                       }

                       ul {
                          font-family: "Tahoma";
                          font-size: 18px;
                       }
                       
                       .parameters {
                          font-family: "Tahoma";
                       }
                       
                       .logos {max-width: 800px; width: 90%; height: auto; margin-left: auto; margin-right: auto; display: block;}
                       '),
            
            tags$script('
                        var dimension = [0, 0];
                        $(document).on("shiny:connected", function(e) {
                        dimension[0] = window.innerWidth;
                        dimension[1] = window.innerHeight;
                        Shiny.onInputChange("dimension", dimension);
                        });
                        
                        $(window).resize(function(e) {
                        dimension[0] = window.innerWidth;
                        dimension[1] = window.innerHeight;
                        Shiny.onInputChange("dimension", dimension);
                        });
                        ')
            ),
  
  
  tabItems(
    # Dashboard tab
    tabItem(tabName="big_picture", 
            
            ##### MAIN DIAGRAM
            
            h1(tags$b("Big picture")),
            
            # Info boxes
            fluidRow(
              valueBoxOutput("years_Box", width = 3),
              valueBoxOutput("convocations_Box", width = 3),
              valueBoxOutput("factions_Box", width = 3),
              valueBoxOutput("mps_Box", width = 3)
            ),
            
            fluidRow(
              
              # Main diagram
              # Instructions
              box(title = "Diagram. All convocations", 
                  status="info", solidHeader = TRUE, width = 9,
                  downloadButton('d_all_factions', 'Download graph'),
                  uiOutput("big_picture_render")
                  ),
              
              # Instructions
              box(title = "Instructions", 
                  status="info", solidHeader = TRUE, width = 3,
                  p(tags$ul(
                    tags$li("Each", strong("node"), "in a diagram represents one faction in a given 
                            convocation;"), 
                    tags$li(strong("Node's name"), "consists of 'faction name' + convocation number, 
                            i.e. 'Nasha Ukraina_6' node represents 'Nasha Ukraina' faction in the 6th 
                            convocation;"), 
                    tags$li("For each faction diagram shows the",
                            strong("previous and future affiliations"), "of its MPs. You 
                            can highlight these connections by hovering over the node;"), 
                    tags$li(strong("The first node"), "'people_pool_0' represents 'a pool of people', i.e. people that previously did not 
                            serve as MPs or were MPs during the first three convocations that are not covered in this 
                            diagram;"),
                    tags$li("To improve readability you can rearange nodes in a vertical dimension;
                            ")
                    )))
            ),
            
            
            
            
            h1(tags$b("Summary")),
            
            p("This tool allows to explore the migration of Ukrainian Members of Parliament (MPs) between Parliaments ", 
            em("(Ukr. Rada)"), "and Factions. Currently, the tool includes information regarding the last seven 
            convocations (1998-2019) including the current convocation. Due to the limited access to high quality data, 
            information regarding erlier two convocations (1990-1998) is not included. Data collection and harmonization 
            for all other years is in progress."),
            
            p(strong('Tool allows to create and save a Sankey diagram relevant to a specific research question.')),
            
            p(strong("Tabs:"), style="color:#595959"),
            
            p(tags$ul(
              tags$li("Current tab provides a", strong("'big picture'"), "- it shows the connections between
                      all the convocations;"), 
              tags$li(strong("Factions"), "tab allows to explore a trajectory of MPs between convocations by factions 
                      of origin and destination;"), 
              tags$li(strong("Radas"), "tab allows user to explore connections between any of two selected convocations 
                      by MPs who served there;"),
              tags$li(strong("MPs"), "tab contains a database of all MPs;")
            )),
            
            p(strong("Source of data:"), style="color:#595959"),
            
            
            p("Data was scrapped from the",
              tags$a(href = "https://rada.gov.ua/", "official website of Ukrainian Parliament"),
              "with a support of the", strong("Office of Naval Research (ONR)"), "N00014-17-1-2675 funding.")

            
            # # show page width
            # textOutput("dec_txt")
            
    ),
    
    #############################
    ######## Factions   ########
    #############################
    
    tabItem(tabName="factions",
            h1(tags$b("Exploring factions")),
            
            p(strong('Possible research questions:')),
            
            p(tags$ul(
              tags$li("How many SDPU(o) MPs survived till 9th convocation?"), 
              tags$li("What MPs moved from Batkivshchyna to Partiya Rehioniv?")
              )),            
            
            fluidRow(
              box(title = "Select a convocation", 
                  status="info", solidHeader = TRUE,
                  tags$div(class = "parameters",
                           radioButtons(inputId="convocation",
                              label=NULL, 
                              choices=c("3rd convocation: 1998-2002"="3",
                                        "4th convocation: 2002-2006"="4",
                                        "5th convocation: 2006-2007"="5",
                                        "6th convocation: 2007-2012"="6",
                                        "7th convocation: 2012-2014"="7",
                                        "8th convocation: 2014-2019"="8",
                                        "9th convocation: 2019-"="9"),
                              selected="7"))
                  ),
              
              box(title = "Select a faction name", 
                  status="info", solidHeader = TRUE,
                  uiOutput("select_faction"))
            ),
            
            # Info boxes
            fluidRow(
              valueBoxOutput("full_name_Box", width = 4),
              valueBoxOutput("mps_faction_Box", width = 3)
            ),
            
            fluidRow(
              
              # Diagram
              box(title = "Diagram. Past and future alliances of MPs from the selected faction", 
                  status="info", solidHeader = TRUE, width = 12,
                  downloadButton('d_faction', 'Download graph'),
                  uiOutput("faction_network_render")
              )
            ),

            # Table with MPs
            fluidRow(
              h3(tags$b("Table of MPs affiliations")),
              DT::dataTableOutput(outputId = "faction_subset")
              
            )
            
            
            
            
    ),

    #############################
    ######## Radas   ########
    #############################
    
    tabItem(tabName="radas",
            h1(tags$b("Exploring connections between convocations")),
            
            p(strong('Possible research question:'), 'which MPs moved from 8th to 9th convocation?'),
            
            fluidRow(
              box(title = "Select two Radas to find common MPs", status="info", solidHeader = TRUE,
                  
                  # Price of decision claim
                  tags$div(class = "parameters",
                           radioButtons(inputId="rada_1",
                                        label="Rada – select one:", 
                                        choices=c("3rd convocation: 1998-2002"="3",
                                                  "4th convocation: 2002-2006"="4",
                                                  "5th convocation: 2006-2007"="5",
                                                  "6th convocation: 2007-2012"="6",
                                                  "7th convocation: 2012-2014"="7",
                                                  "8th convocation: 2014-2019"="8",
                                                  "9th convocation: 2019-"="9"),
                                        selected="4"),
                           
                           uiOutput("second_rada")
                  )
              ),
              valueBoxOutput("mps_rada_Box", width = 3)
            ),
            
            fluidRow(
              
              # Diagram
              box(title = "Diagram. Connections between two Radas", 
                  status="info", solidHeader = TRUE, width = 12,
                  downloadButton('d_rada', 'Download graph'),
                  uiOutput("radas_network_render")
              )
            ),
            
            
            # Table with MPs
            fluidRow(
              h3(tags$b("Table of MPs affiliations")),
              DT::dataTableOutput(outputId = "radas_subset")
              
            )
    ),

    
    #############################
    ######## MPs   ########
    #############################
    
    tabItem(tabName="mps",
            h1(tags$b("Information about individual MPs")),
            
            fluidRow(
              box(title = "Filter using Ukr or Eng name", status="info", solidHeader = TRUE, width=4,
                  
                  # Price of decision claim
                  tags$div(class = "parameters",
                           radioButtons(inputId="language",
                                        label=NULL, 
                                        choices=c("English"="name_eng",
                                                  "Ukrainian"="name_ukr"),
                                        selected="name_eng")
                  )
              ),
              
              box(title = "Select an MP", status="info", solidHeader = TRUE, width=8,
                  
                  # Price of decision claim
                  tags$div(class = "parameters",
                           uiOutput("MPS_names")
                           
                  )
              )
            ), 
            
            fluidRow(
              h3(tags$b("Summary information for the selected MP")),
              DT::dataTableOutput(outputId = "mp_summary")
              
            )
    )
  )
)


shinyUI(dashboardPage(skin = "yellow", header, sidebar, body))

