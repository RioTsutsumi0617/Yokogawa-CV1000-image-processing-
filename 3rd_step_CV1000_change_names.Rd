library(dplyr)
setwd("/Volumes/G-DRIVE Thunderbolt 3/CV1000/20221130T225007/")
tab <- read.csv("ImageIndex.csv")
tab <- mutate(tab, W = gsub(".*W(.+)F.*", "\\1", path))
tab <- mutate(tab, NewNames = paste(Column,LETTERS[Row],".tif", sep=""))
tab <- mutate(tab, TiffNames = paste("W", W, ".tif", sep=""))

tab2 <- subset(tab, ,c(NewNames, TiffNames))
tab2 <- unique(tab2)

setwd("Image/hyperstack")
file.rename(tab2$TiffNames, tab2$NewNames)


