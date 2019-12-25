





###################################
#######        SERVER      ########
###################################

shinyServer(function(input, output) {
  
  ##### Download data #####
  
  links_total <- readRDS(file = "./www/links_total.rds")
  nodes_total <- readRDS(file = "./www/nodes_total.rds")
  
  # Download DF with unique faction names
  convocation_factions <- readRDS(file = "./www/convocation_factions.rds")
  
  # Download all the links
  df_links <- readRDS(file = "./www/prepare_links.rds")
  
  # download the MPs database
  #df_database <-  readRDS(file = "./www/df_database.rds")
  df_database <- read.csv2('./www/df_database_ver2.csv', header=TRUE, sep=',', encoding='UTF-8')
  
  # support functions
  eval(parse("./radas_func.R", encoding="UTF-8"))
  
  datatable_options <- list(paging = FALSE,
                            searching = TRUE,
                            fixedColumns = TRUE,
                            autoWidth = FALSE,
                            ordering = TRUE,
                            dom = 'Bfrtip',
                            buttons = c('csv', 'excel'))
  
  ###################################
  #######     Big picture     #######
  ###################################
  
  # diagram with all factions
  output$big_picture <- renderSankeyNetwork({
    create_network(links_total, nodes_total)
  })
  
  # button to save diagram with all factions
  output$d_all_factions <- downloadHandler(
    filename = 'ua_parliament_all_factions.html',
    content = function(file) {
      saveNetwork(create_network(links_total, nodes_total), file)
    },
    contentType='text/html'
  )
  
  
  # vals$collapsed checks if sidebat is collapsed
  vals=reactiveValues()
  vals$collapsed=FALSE
  observeEvent(input$SideBar_col_react,
               { vals$collapsed=!vals$collapsed }
  )
  
  get_width <- reactive({
    # Make sure requirements are met
    req(input$dimension)
    return(input$dimension[1])
  })
  
  get_height <- reactive({
    # Make sure requirements are met
    req(input$dimension)
    height = input$dimension[2]
    return(paste(round(height*0.8), 'px', sep=''))
  })
  
  check_collapsed <- reactive({
    return(vals$collapsed)
  })
  
  output$big_picture_render <- renderUI({
    
    width = get_width()
    multiplier = ifelse(check_collapsed(), 0.9, 0.8)
    share_of_window = 9/12
    
    width_text = paste(round(width*share_of_window*multiplier), 'px', sep='')
    
    sankeyNetworkOutput("big_picture",
                        width=width_text,height=get_height())
  })
  
  
  # Pop-up window for mobile devices
  vals$first_warning=TRUE
  
  observe({
    if(get_width()<1000 & vals$first_warning){
      showModal(modalDialog(
        title = HTML('<p><b>Warning</b></p>'),
        HTML('<p>This app is currently not optimized for small screen viewing. We apologize for this.
             </p>'),
        size = "l",
        footer = modalButton("Close")
        ))
      vals$first_warning=FALSE
    }
  })
  
  
  ###################################
  #######     Value boxes     #######
  ###################################
  
  output$years_Box <- renderValueBox({ valueBox(value='1998-2019',
                                                subtitle=tags$p("years covered", style = "font-size: 200%;"),
                                                icon=icon("calendar-alt"),
                                                color='orange')})
  
  output$convocations_Box <- renderValueBox({ valueBox(value='7',
                                                subtitle=tags$p("convocations", style = "font-size: 200%;"),
                                                icon=icon("poll"),
                                                color='orange')})
  
  
  output$factions_Box <- renderValueBox({ valueBox(value='73',
                                                    subtitle=tags$p("factions", style = "font-size: 200%;"),
                                                       icon=icon("handshake"),
                                                       color='orange')})
  
  
  output$mps_Box <- renderValueBox({ valueBox(value='2,038',
                                              subtitle=tags$p("unique MPs", style = "font-size: 200%;"),
                                                       icon=icon("users"),
                                                       color='orange')})
  
  # # Display screen width
  # output$dec_txt <- renderText({
  #   paste(vals$collapsed, '    ',
  #         input$dimension[1], 'px    ',
  #         get_f_full_name(), '  ',
  #         nrow(get_f_df()), sep='')
  # })
  
  ###################################
  #######     Factions       #######
  ###################################
  
  # Get the convocation number
  get_f_convocation <- reactive({
    return(as.integer(input$convocation))
  })
  
  # Get DF with the faction names that belong to the selected convocation
  get_f_df <- reactive({
    return(convocation_factions[convocation_factions$rada_number==get_f_convocation(),])
  })

  # Render UI for the faction selection
  output$select_faction <- renderUI({
    f_df = get_f_df()
    radioButtons(inputId="faction",
                label=NULL, 
                choiceNames = f_df$target_new,
                choiceValues = f_df$target_new,
                selected = f_df$target_new[1])
  })
  
  # Get the full name of selected faction
  get_f_full_name <- reactive({
    return(paste(input$faction,input$convocation,sep='_'))
  })
  
  # Create a subset of links with MPs that belonged to the selected faction
  get_f_links_subset <- reactive({
    
    target_name = paste('target', get_f_convocation(), sep="_")
    faction_name = get_f_full_name()
    
    df_links_sub = df_links[(df_links[,target_name]==faction_name) &
                                         (!is.na(df_links[,target_name])),]
    
    return(df_links_sub)
  })
  
  
  ##### Value boxes
  output$full_name_Box <- renderValueBox({ valueBox(value=get_f_full_name(),
                                                    subtitle=tags$p("selected faction",
                                                                    style = "font-size: 200%;"),
                                                    icon=icon("handshake"),
                                                    color='orange')})
  
  
  output$mps_faction_Box <- renderValueBox({ valueBox(value=nrow(get_f_links_subset()),
                                              subtitle=tags$p("unique MPs", style = "font-size: 200%;"),
                                              icon=icon("users"),
                                              color='orange')})
  
  
  ##### Factions diagram
  
  get_f_links_nodes <- reactive({
    
    fac_links = get_fac_links(get_f_links_subset())
    fac_nodes = get_fac_nodes(nodes_total, fac_links)
    fac_links = get_fac_links_final(fac_nodes, fac_links)
    
    return(list(fac_links, fac_nodes))
  })
  
  
  output$faction_network <- renderSankeyNetwork({
    links_nodes = get_f_links_nodes()
    create_network(links_nodes[[1]], links_nodes[[2]])
  })
  
  
  # button to save diagram with one faction
  output$d_faction <- downloadHandler(
    filename = function(){
      paste(get_f_full_name(),'.html',sep='')
    },
    content = function(file) {
      links_nodes = get_f_links_nodes()
      saveNetwork(create_network(links_nodes[[1]], links_nodes[[2]]), file)
    },
    contentType='text/html'
  )
  
  output$faction_network_render <- renderUI({
    
    width = get_width()
    multiplier = ifelse(check_collapsed(), 0.9, 0.8)
    share_of_window = 9/12
    
    width_text = paste(round(width*share_of_window*multiplier), 'px', sep='')
    
    sankeyNetworkOutput("faction_network",
                        width=width_text)
  })
  
  
  # create table
  output$faction_subset <- DT::renderDataTable({
    
    caption_txt = paste('Table 1: Affiliations of MPs that belonged to', get_f_full_name())
    
    DT::datatable(data = prettify(get_f_links_subset()),
                  caption = caption_txt,
                  extensions = 'Buttons',
                  options = datatable_options, 
                  rownames = FALSE)
  })
  

  
  ###################################
  #######       Radas         #######
  ###################################
  
  get_first_rada <- reactive({
    req(input$rada_1)
    return(input$rada_1)})
  
  get_second_rada <- reactive({
    req(input$rada_2)
    return(input$rada_2)})
  
  # Render UI for the 2nd selected Rada
  output$second_rada <- renderUI({
    
    choices = c("3rd convocation: 1998-2002"="3",
                "4th convocation: 2002-2006"="4",
                "5th convocation: 2006-2007"="5",
                "6th convocation: 2007-2012"="6",
                "7th convocation: 2012-2014"="7",
                "8th convocation: 2014-2019"="8",
                "9th convocation: 2019-"="9")
    
    choices = choices[choices!=get_first_rada()]
    
    
    radioButtons(inputId="rada_2",
                 label='Rada – select another:', 
                 choices = choices,
                 selected = choices[1])
  })
  
  
  # Create a subset of links with MPs that belonged to both Radas
  get_r_links_subset <- reactive({
    
    target_1 = paste('target', get_first_rada(), sep="_")
    target_2 = paste('target', get_second_rada(), sep="_")
    
    df_links_sub = df_links[(!is.na(df_links[,target_1])) &
                            (!is.na(df_links[,target_2])),]
    
    return(df_links_sub)
  })
  
  # Value boxes
  output$mps_rada_Box <- renderValueBox({ valueBox(value=nrow(get_r_links_subset()),
                                                       subtitle=tags$p("unique MPs in both Radas", style = "font-size: 200%;"),
                                                       icon=icon("users"),
                                                       color='orange')})
  
  
  ##### Radas diagram
  
  get_r_links_nodes <- reactive({
    
    rada_links = get_fac_links(get_r_links_subset(), all_factions=FALSE,
                               rada_1=get_first_rada(), rada_2=get_second_rada())
    rada_nodes = get_fac_nodes(nodes_total, rada_links)
    rada_links = get_fac_links_final(rada_nodes, rada_links)
    
    return(list(rada_links, rada_nodes))
  })
  
  output$radas_network <- renderSankeyNetwork({
    links_nodes = get_r_links_nodes()
    create_network(links_nodes[[1]], links_nodes[[2]])
  })
  
  # button to save diagram with two radas
  output$d_rada <- downloadHandler(
    filename = function(){
      paste('conv_', get_first_rada(), '_and_', get_second_rada(),
            '.html',sep='')
    },
    content = function(file) {
      links_nodes = get_r_links_nodes()
      saveNetwork(create_network(links_nodes[[1]], links_nodes[[2]]), file)
    },
    contentType='text/html'
  )
  
  output$radas_network_render <- renderUI({
    
    width = get_width()
    multiplier = ifelse(check_collapsed(), 0.9, 0.8)
    share_of_window = 9/12
    
    width_text = paste(round(width*share_of_window*multiplier), 'px', sep='')
    
    sankeyNetworkOutput("radas_network",
                        width=width_text)
  })
  
  
  # create table
  output$radas_subset <- DT::renderDataTable({
    
    rada_1 = get_first_rada()
    rada_2 = get_second_rada()
    caption_txt = paste('Table 2: MPs that served in convocation',rada_1,'and',rada_2)
    
    DT::datatable(data = prettify(get_r_links_subset()),
                  caption = caption_txt,
                  extensions = 'Buttons',
                  options = datatable_options, 
                  rownames = FALSE)
    

  })
  
  ###################################
  #######       MPs        #######
  ###################################
  
  get_language <- reactive({
    req(input$language)
    return(input$language)
  })
  
  
  output$MPS_names <- renderUI({
    
    lang = get_language()
    names = df_database[,lang]
    selectInput(inputId="name",
                label=NULL, 
                choices=names,
                selected=names[1], multiple=FALSE)
  })
  
  get_name <- reactive({
    req(input$name)
    return(input$name)
  })
  
  
  # create table
  output$mp_summary <- DT::renderDataTable({
    
    name = get_name()
    
    df = get_mp_info(df_database, name, language=get_language())
    caption_txt = paste('Table 3: Information about', name)
    
    DT::datatable(data = df, 
                  caption = caption_txt,
                  extensions = 'Buttons',
                  options = datatable_options, 
                  rownames = FALSE) %>% formatStyle(
                    'variables',
                    backgroundColor = '#CDCDCD',
                    fontWeight = 'bold',
                    fontSize = '16px'
                  )
  })
  
  })
