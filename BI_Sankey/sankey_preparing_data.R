
############## Setup ##############

library(stringr)
library(networkD3)
library(dplyr)
library(tidyr)

directory_working <- "C:/Users/Oleksa/Documents/Projects/Rada_networks"
setwd(directory_working)

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

saveRDS(df_mp, file = "df_database.rds")

write.csv(df_mp, file='df_database.csv', row.names = FALSE)

############## DF with only faction info ##############

df_total <- df_mp[,c('name_eng','faction','convocation')]
  
# One person is accounted twice under different names
df_total <- df_total[df_total$name_eng!='Bordyuh Inna Leonidivna',]

df_total <- df_total %>%
  rename(rada_number = convocation)
  
df_total$target_new <- df_total[,'faction']


############## Add 'zero' Rada with all unique names ##############

df_zero <- data.frame('name_eng'=unique(df_total$name_eng),
                      'rada_number'=0)
df_zero[,'faction'] <- 'people_pool'
df_zero$target_new <- 'people_pool'

df_total <- rbind(df_total, df_zero)

df_total$name_full <- paste(df_total$target_new, df_total$rada_number, sep='_')
df_total$rada_number <- as.numeric(df_total$rada_number)

rm(df_zero)

df_total <- df_total[order(df_total$rada_number, df_total$target_new),]


############## Prepara dataframes for the diagram ##############

# From these flows we need to create a node data frame: it lists every entities involved in the flow
nodes <- data.frame(
  name=c(df_total$name_full) %>% unique()
)

rada_numbers <- unique(df_total$rada_number)


###### Initial data
Rada <- rada_numbers[1]
target_name <- paste('target', Rada,sep='_')
prepare_links <- df_total[df_total$rada_number==Rada,c('name_eng','name_full')]
colnames(prepare_links) <- c('name_eng',target_name)


####### Every real Rada
for(Rada in rada_numbers[2:length(rada_numbers)]){
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
saveRDS(links, file = "links_total.rds")
saveRDS(nodes, file = "nodes_total.rds")

######
convocation_factions <- subset(df_total,
                               subset=!duplicated(df_total$name_full),
                               select=c('rada_number','target_new','name_full'))

convocation_factions <- convocation_factions[convocation_factions$rada_number!=0,]

saveRDS(convocation_factions, file = "convocation_factions.rds")

######
saveRDS(prepare_links, file = "prepare_links.rds")


