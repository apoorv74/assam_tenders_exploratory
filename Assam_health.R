## next steps include extracting only village and district level information from names, getting a unique set of values? and mapping it to existing dataset 
#First I attempt to get places associated with the tender - currently only a 1000 show up
library(dplyr)
library(stringi)
library(tidyverse)
assam_published <- read.csv("assam_tenders_published.csv", header = T, stringsAsFactors = F)
assam_list <- read.csv("Census Combined (all in one sheet) - All together.csv",  header=T, stringsAsFactors = F)
assam_list1 <- read.csv("assam_list.csv", stringsAsFactors = F)

assam_list <- assam_list %>% filter (Level == "VILLAGE")
assam_list$Name <- gsub("\\)|\\(", "", assam_list$Name)
assam_published$tender_title <- gsub("\\)|\\(", "", assam_published$tender_title)

#Method 1
idx2 <- sapply(assam_published$tender_title, grep, assam_list$Name)
idx1 <- sapply(seq_along(idx2), function(i) rep(i, length(idx2[[i]])))
assam_published_1<- cbind(assam_published[unlist(idx1),,drop=F], assam_list$Name[unlist(idx2),,drop=F])


#method3
ff = function(x, patterns, replacements = patterns, fill = NA, ...)
{
  stopifnot(length(patterns) == length(replacements))
  
  ans = rep_len(as.character(fill), length(x))    
  empty = seq_along(x)
  
  for(i in seq_along(patterns)) {
    greps = grepl(patterns[[i]], x[empty], ...)
    ans[empty[greps]] = replacements[[i]]  
    empty = empty[!greps]
  }
  
  return(ans)
}






#Method 3
nameinstate <-  lapply(
  assam_list$Name,
  function(i){
    place = grepl(x = tolower(assam_published$tender_title), pattern = tolower(i))
    if (sum(place) > 0) {
      data.frame(
        assam_published_1 = assam_published[place,],
        i = i
      )
    } else {
      data.frame(
        assam_published_1= assam_published[,],
        i = "N/A"
      )
    }
  }
)

assam_published<- do.call(rbind, nameinstate)

nameinstate2 <-  lapply(
  assam_list$Name,
  function(y){
    place = grepl(x = tolower(assam_published$tender_reference_no), pattern = tolower(y))
    if (sum(place) > 0) {
      data.frame(
        assam_published = assam_published[place,],
        y = y
      )
    } else {
      data.frame(
        assam_published_1= assam_published[,],
        y = "N/A"
      )
    }
  }
)
assam_published <- do.call(rbind, nameinstate2)

nameinstate3 <-  lapply(
  assam_list$Name,
  function(x){
    place = grepl(x = tolower(assam_published$Org), pattern = tolower(x))
    if (sum(place) > 0) {
      data.frame(
        assam_published = assam_published[place,],
        x = x
      )
    } else {
      data.frame(
        assam_published_1= assam_published[,],
        x = "N/A"
      )
    }
  }
)
assam_published <- do.call(rbind, nameinstate3)



##Then I Extract the medical tender data

text = c("NATIONAL HEALTH MISSION", "HEALTH AND FAMILY WELFARE DEPARTMENT")
assam_health<- filter(assam_published, grepl('NATIONAL HEALTH MISSION|HEALTH AND FAMILY WELFARE DEPARTMENT', Org))

assam_health1 <- filter(assam_published, grepl('NH DEPARTMENT', Org))

Keywords <- c(
  "MEDICAL COLLEGE",
  "Dispensary",
  "LABOUR ROOM",
  "PHC",
  "CHC",
  "Pharmacy",
  "GMC",
  "SURGERY",
  "NURSING COLLEGE",
  "Ayush",
  "AYURVEDIC",
  "Morgue",
  "ORTHOPAEDICS",
  "ORTHOPEDICS",
  "Nurse",
  "Homeo",
  "MATERNITY",
  "CLINICAL",
  "JMCH",
  "IVF CENTRE",
  "MEDICAL GAS",
  "ANGANWADI",
  "CREMATION",
  "HOSPITAL",
  "DOCTOR",
  "GNM")

assam_health1 <- assam_health1 %>%
  filter(grepl(paste(Keywords, collapse="|"), tender_title))

assam_health2 <- filter(assam_published, grepl('SOCIAL WELFARE DEPARTMENT', Org))
assam_health2 <- filter(assam_published, grepl('ICDS', tender_reference_no))

assam_health3 <- filter(assam_published, grepl('RASHTRIYA MADHYAMIK SIKSHA ABHIJAN', Org))
assam_health3 <- filter(assam_published, grepl('Healthcare', tender_title))

assam_health_final<- rbind(assam_health, assam_health1, assam_health2, assam_health3)

