
### See do file for details

#Define the function:
chels_fun <- function(start, end, path){
  list.of.packages <- c("dplyr", "gdata")   #install relevant packages if needed:
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  library(dplyr)
  library(gdata)
  file <- paste0(path, "MF", start, ".D/REPORT01.xls")
  jo <- tbl_df(read.xls(file, 21))
  jo <- jo%>% 
    #create the categories: 
    mutate(Time_cat=round(RetTime,2))%>%
    dplyr::select(Time_cat, RetTime, Area)
  colnames(jo) <- c("Time_cat", paste0("Area.",start), paste0("RetTime.", start))
  # Do the same for the rest of the samples:
  a=start+1
  for (i in a:end){
    file <- paste0(path, "MF",i, ".D/REPORT01.xls")
    dat <- tbl_df(read.xls(file, 21))
    dat <- dat%>% 
      mutate(Time_cat=round(RetTime,2))%>%
      dplyr::select(Time_cat, RetTime, Area)
    #join to the rest of the samples
    colnames(dat) <- c("Time_cat", paste0("Area.",i), paste0("RetTime.", i))
    jo <- full_join(jo, dat, by="Time_cat")
  }
  
  jo <- arrange(jo, Time_cat)
}



