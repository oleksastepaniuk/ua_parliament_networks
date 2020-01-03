
############## Setup ##############

library(stringr)
library(networkD3)
library(htmlwidgets) # to save network with saveWidget
library(dplyr)
library(tidyr)


############## A database with the MPs info ##############

df_mp <- read.csv('./mps_combined.csv', sep=",", header=TRUE)

df_mp <- df_mp[,c('name_eng', 'name_ukr', 'convocation', 'party', 'faction', 'faction_position',
                  'elected', 'to_exec_judicial', 'committee')]
    
# change format of columns from factor to character
for(column in colnames(df_mp)){
      df_mp[,column] <- as.character(df_mp[,column])
}
rm(column)

# filter values
df_mp <- df_mp[df_mp$faction!='Institution',]

# saveRDS(df_mp, file = "df_database.rds")

write.csv(df_mp, file='./BI_Sankey_code/www/df_database.csv', row.names = FALSE)

############## DF with only faction info ##############

df_total <- df_mp[,c('name_eng','faction','convocation')]
  
# One person is accounted twice under different names
df_total <- df_total[df_total$name_eng!='Bordyuh Inna Leonidivna',]

df_total <- df_total %>%
  rename(rada_number = convocation)
  
df_total$target_new <- df_total[,'faction']


############## Add 'zero' Rada with all unique names ##############

df_zero <- data.frame('name_eng'=unique(df_total$name_eng),
                      'rada_number'='')
df_zero[,'faction'] <- 'new_MPs'
df_zero$target_new <- 'new_MPs'

df_total <- rbind(df_total, df_zero)

df_total$name_full <- paste(df_total$target_new, df_total$rada_number, sep='_')
df_total$name_full <- ifelse(df_total$target_new=='new_MPs', 'new_MPs', df_total$name_full)
df_total$rada_number <- as.numeric(df_total$rada_number)

rm(df_zero)

df_total <- df_total[order(df_total$rada_number, df_total$target_new),]


############## Prepara dataframes for the diagram ##############

# From these flows we need to create a node data frame: it lists every entities involved in the flow
nodes <- data.frame(
  name=c(df_total$name_full) %>% unique()
)

rada_numbers <- unique(df_total$rada_number)
rada_numbers <- rada_numbers[!is.na(rada_numbers)]


###### Initial data
prepare_links <- df_total[df_total$name_full=='new_MPs',c('name_eng','name_full')]
colnames(prepare_links) <- c('name_eng', 'target_0')


####### Every real Rada
for(Rada in rada_numbers){
  next_Rada <- df_total[df_total$rada_number==Rada,c('name_eng','name_full')]
  prepare_links <- merge(prepare_links, next_Rada,
                         by=c('name_eng'), all.x=TRUE)
  colnames(prepare_links)[ncol(prepare_links)] <- paste('target', Rada, sep='_')
}


############## Complete Diagram ##############

find_source <- function(row_sources){
  for(i in seq(length(row_sources),1)){
    if(!is.na(row_sources[[i]])){
      source = row_sources[[i]]
      break
    }
  }
  return(source)
}

source_columns <- colnames(prepare_links)[2:(length(prepare_links)-1)]
target_columns <- colnames(prepare_links)[3:length(prepare_links)]
first_Rada <- TRUE

for(i in seq(length(target_columns))){
  target <- target_columns[i]
  sources <- source_columns[1:i]
  
  df_target <- prepare_links[!is.na(prepare_links[,target]),c(sources,target)]
  
  if(first_Rada){
    links <- df_target
    colnames(links) <- c('source', 'target')
    first_Rada <- FALSE
  } else {
    df_target$source <- apply(df_target[,sources], 1, find_source)
    df_target <- df_target[,c(target,'source')]
    colnames(df_target) <- c('target','source')
    links <- rbind(links,df_target)
  }
}


links$IDsource <- match(links$source, nodes$name)-1 
links$IDtarget <- match(links$target, nodes$name)-1

links$value <- 0.5


############### Saving data #####################

######
saveRDS(links, file = "./BI_Sankey_code/www/links_total.rds")
saveRDS(nodes, file = "./BI_Sankey_code/www/nodes_total.rds")

######
convocation_factions <- subset(df_total,
                               subset=!duplicated(df_total$name_full),
                               select=c('rada_number','target_new','name_full'))

convocation_factions <- convocation_factions[convocation_factions$rada_number!=0,]

saveRDS(convocation_factions, file = "./BI_Sankey_code/www/convocation_factions.rds")

######
saveRDS(prepare_links, file = "./BI_Sankey_code/www/prepare_links.rds")


##################### Detailed diagram

# Make the Network
diagram <- sankeyNetwork(Links = links, Nodes = nodes,
                         Source = "IDsource", Target = "IDtarget",
                         Value = "value", NodeID = "name", 
                         sinksRight=FALSE,
                         fontSize = 14,
                         nodeWidth = 15, width=1500, height=750)

# save
file_name <- ".\\BI_Sankey_code\\www\\big_picture_detailed.html"
saveWidget(diagram, file.path(normalizePath(dirname(file_name)),basename(file_name)), selfcontained = TRUE)
rm(file_name)
unlink(".\\BI_Sankey_code\\www\\big_picture_detailed_files", recursive=TRUE) # in addition ti html file a folder is created



############################### Simplified network

prepare_simplified <- prepare_links
nodes <- c('new_MPs')

for(target in target_columns){
  # Get the convocation number
  convocation <- as.numeric(str_extract(target, "\\d+"))
  convocation <- paste('Rada', convocation, sep='_')
  nodes <- c(nodes, convocation)
  prepare_simplified[,target] <- ifelse(is.na(prepare_simplified[,target]), NA, convocation)
  print(convocation)
}

nodes <- data.frame(
  name=nodes
)

first_Rada <- TRUE

for(i in seq(length(target_columns))){
  target <- target_columns[i]
  sources <- source_columns[1:i]
  
  df_target <- prepare_simplified[!is.na(prepare_simplified[,target]),c(sources,target)]
  
  if(first_Rada){
    links <- df_target
    colnames(links) <- c('source', 'target')
    first_Rada <- FALSE
  } else {
    df_target$source <- apply(df_target[,sources], 1, find_source)
    df_target <- df_target[,c(target,'source')]
    colnames(df_target) <- c('target','source')
    links <- rbind(links,df_target)
  }
}
rm(i,sources,target)

links$IDsource <- match(links$source, nodes$name)-1 
links$IDtarget <- match(links$target, nodes$name)-1

links$value <- 0.5

# Make the Network
diagram <- sankeyNetwork(Links = links, Nodes = nodes,
                         Source = "IDsource", Target = "IDtarget",
                         Value = "value", NodeID = "name", 
                         sinksRight=FALSE,
                         fontSize = 14,
                         nodeWidth = 20, width=1000, height=500)

# save
file_name <- ".\\BI_Sankey_code\\www\\big_picture_simplified.html"
saveWidget(diagram, file.path(normalizePath(dirname(file_name)),basename(file_name)), selfcontained = TRUE)
rm(file_name)
unlink(".\\BI_Sankey_code\\www\\big_picture_simplified_files", recursive=TRUE) # in addition ti html file a folder is created





