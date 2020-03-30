# Packages ---- 
pkgs <- c('tidyverse', 'googlesheets4', 'glue', 'gluedown', 'rmarkdown', 'stringr')
for (pkg in 1:length(pkgs)){
  if(pkgs[pkg] %in% rownames(installed.packages())==F) {install.packages(pkgs[pkg])}
  library(pkgs[pkg], character.only=TRUE)
}

# load sheets ---- 

## events ---- 
events <- sheets_read("https://docs.google.com/spreadsheets/d/1QiDO_-b9i0yFPxzUUHxmXXWdNJFHFBKiLC9ughdsxVM/edit?usp=sharing", sheet = 1, col_types = "c")
events$post_date <- seq.Date(as.Date("2020-01-01"), by=1, length.out = nrow(events))
events$title <- paste0(word(events$`Event Description`, 1, 5),"...")
events$title_path <- word(events$`Event Description`, 1, 5)
events <- filter(events, !is.na(`Event Description`))%>%
  mutate(`Event Image Location`=replace_na(`Event Image Location`,""))
  
## resources ---- 
resources <- sheets_read("https://docs.google.com/spreadsheets/d/1QiDO_-b9i0yFPxzUUHxmXXWdNJFHFBKiLC9ughdsxVM/edit?usp=sharing", sheet = 2, col_types = "c", skip = 1)
colnames(resources)[1] <- "resource_type"
resources[1,1] <- "Anti-Rent War Books"
resources <- fill(resources, resource_type)
resources$post_date <- seq.Date(as.Date("2020-01-01"), by=1, length.out = nrow(events))
resources$title <- paste0(word(resources$`Note/Description`, 1, 5),"...")
resources$title_path <- word(resources$`Note/Description`, 1, 5)
resources <- resources %>%
  filter(!is.na(Author))%>%
  mutate(Title=ifelse(is.na(Title),Author, Title),
         `Note/Description`=ifelse(is.na(`Note/Description`),Title,`Note/Description`),
         `Link w/image`=replace_na(`Link w/image`,""))

## map data ---- 
map_data <- sheets_read("https://docs.google.com/spreadsheets/d/1QiDO_-b9i0yFPxzUUHxmXXWdNJFHFBKiLC9ughdsxVM/edit?usp=sharing", sheet = 3, col_types = "c")

# create markdown text ---- 

## events md ----
event_posts <- glue(
'---
layout: post
title: {events$title}
date: {events$post_date}
categories: 
  - Juice
description: {events$`Event Description`}
image: {events$`Event Image Location`}
image-sm: {events$`Event Image Location`}
---
{events$`Event Description`}')

## resources md ----
resources_posts <- glue(
  '---
layout: post
title: "{resources$Title}, by {resources$Author}"
date: {resources$post_date}
categories: 
  - Resources
  - {resources$resource_type}
description: {resources$`Note/Description`}
image: {resources$`Link w/image`}
image-sm: {resources$`Link w/image`}
---
{resources$`Note/Description`}')


# saveout md files ---- 
#sink("writing/test.md")
#cat(event_posts[1])
#sink()

## events save ---- 
for (i in 1:length(event_posts)){
  sink(paste0("~/websites/trophy-jekyll/_posts/",as.character(events$post_date)[i],"-",str_replace_all(tolower(str_replace_all(events$title_path[i], "[[:punct:]]", "")),"\\s+","_"),".md"))
  cat(event_posts[i])
  sink()
}

