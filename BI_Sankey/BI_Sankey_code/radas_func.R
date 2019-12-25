

find_source <- function(row_sources){
  for(i in seq(length(row_sources),1)){
    if(!is.na(row_sources[[i]])){
      source = row_sources[[i]]
      break
    }
  }
  return(source)
}



get_fac_links <- function(links, all_factions=TRUE, rada_1=NULL, rada_2=NULL) {
  first_Rada <- TRUE
  if(all_factions){
    target_columns = c("target_3", "target_4", "target_5", "target_6", "target_7", "target_8", "target_9")
    source_columns = c("target_0",  "target_3", "target_4", "target_5", "target_6", "target_7", "target_8")
  } else {
    radas = c(as.integer(rada_1), as.integer(rada_2))
    rada_smaller = min(radas)
    rada_bigger = max(radas)
    source_columns = c(paste('target',rada_smaller,sep='_'))
    target_columns = c(paste('target',rada_bigger,sep='_'))
  }

  for(i in seq(length(target_columns))){
    
    target <- target_columns[i]
    sources <- source_columns[1:i]
    
    df_target_sub <- links[!is.na(links[,target]),c(sources,target)]
    
    if(first_Rada){
        links_sub <- df_target_sub
        colnames(links_sub) <- c('source', 'target')
        first_Rada <- FALSE
    } else {
        df_target_sub$source <- apply(df_target_sub[,sources], 1, find_source)
        df_target_sub <- df_target_sub[,c(target,'source')]
        colnames(df_target_sub) <- c('target','source')
        links_sub <- rbind(links_sub,df_target_sub)
    }
  }
  
  return(links_sub)
}



get_fac_nodes <- function(nodes, links_sub) {
  nodes_sub = data.frame(name=
                          nodes[nodes$name %in% unique(c(links_sub$target, links_sub$source)),])
  return(nodes_sub)
}

get_fac_links_final <- function(nodes_sub, links_sub){
  links_sub$IDsource <- match(links_sub$source, nodes_sub$name)-1 
  links_sub$IDtarget <- match(links_sub$target, nodes_sub$name)-1
  
  links_sub$value <- 0.5
  
  return(links_sub)
}


prettify <- function(df){
    
  df$target_0 = NULL
  colnames(df) = c('MP name', '3rd_convoc', '4th_convoc', '5th_convoc', '6th_convoc',
                   '7th_convoc', '8th_convoc', '9th_convoc')
    
  return(df)
}



get_mp_info <- function(df, name, language){
  
  df_subset = df[df[,language]==name,]
  df_subset = df_subset[,3:ncol(df_subset)]
  
  # first remember the names
  conv <- df_subset$convocation
  for(i in 1:length(conv)){
    conv[i] = paste(conv[i], 'th_convoc', sep='')
  }
  
  # transpose all but the first column (convocation)
  df_wide <- as.data.frame(t(df_subset[,-1]))
  colnames(df_wide) <- conv
  df_wide$variables <- c('Party', 'Faction', 'Faction position',
                         'Elected', 'Switched to exec/judicial', 'Committee')
  n_col = ncol(df_wide)

  df_wide <- df_wide[, c(n_col,seq(1,n_col-1))]
  
  return(df_wide)
}


# name = df_database$name_eng[12]
# column = 'name_eng'



create_network <- function(links, nodes){
  network = sankeyNetwork(Links = links, Nodes = nodes,
                          Source = "IDsource", Target = "IDtarget",
                          Value = "value", NodeID = "name",
                          sinksRight=FALSE,
                          fontSize=14, nodeWidth=20)
  return(network)
}






  
  
  
  
