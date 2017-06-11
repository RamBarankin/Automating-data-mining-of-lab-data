The problem
-----------

A master's student have told me that her adviser is spending $10k (!) a
year for hiring students to organize excel data. They have been using a
lab tool that analyzes chemical samples (I don't have any idea of what),
and the relevant part (for them) of the output of the analysis is
located in the 21st sheet of an Excel file that is saved inside a
separate folder for each sample (!). They are manually doing two things:

1.  Going into each folder of each sample, going to the last sheet and
    copying and pasting the relevant columns to a joint sheet in a
    different Excel file. Each sample file was named
    MF<sample number>.D.xls (e.g., MF744.D).

2.  Organizing the data according to different categories (that are the
    rounded value of two digits of one of the relevant variables). The
    PI apparently stated several time that experts (?) told her that
    this process cannot be automated.

### Challenge accepted

At first I thought I am missing something, but I soon to find out that I
can easily automate the process in R by creating the following function:

    #Define the function:
    chels_fun <- function(start, end, path){
      #install relevant packages if needed:
      list.of.packages <- c("dplyr", "gdata")
      new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
      if(length(new.packages)) install.packages(new.packages)
      #load packages:
      library(dplyr)
      library(gdata)
      #load the first sheet:
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

Then, all my friend is needed to do is define the samples number range
and the path to where the samples files are located and she gets a data
frame that has all she needed.

    source("chels_fun.R") #load the function
    start<-744 #the first sample number
    end<-747 #the last sample number
    path <-("Sample data/")# the location of the sample folders (not including the sample folders themselfs!)
    dat <- chels_fun(start,end,path)
    dat #print the results (this will print only the first 10 lines, since it is a dplyr tbl_df data frame)

    ## # A tibble: 89 × 9
    ##    Time_cat  Area.744 RetTime.744  Area.745 RetTime.745  Area.746
    ##       <dbl>     <dbl>       <dbl>     <dbl>       <dbl>     <dbl>
    ## 1      3.10  3.101069  2377.08057        NA          NA        NA
    ## 2      3.11        NA          NA  3.107622  4209.79785  3.107622
    ## 3      3.53  3.530716  1104.51636        NA          NA        NA
    ## 4     11.31 11.308692   615.69073 11.310547   778.59448 11.310547
    ## 5     11.83        NA          NA 11.828438    45.81472 11.828438
    ## 6     12.06        NA          NA 12.063776    31.54520 12.063776
    ## 7     12.30 12.299639    56.99836 12.299285   104.39632 12.299285
    ## 8     12.88 12.876271   593.87915 12.881848  1022.73517 12.881848
    ## 9     14.02 14.019990  2511.21509        NA          NA        NA
    ## 10    14.05        NA          NA 14.050228  4456.63818 14.050228
    ## # ... with 79 more rows, and 3 more variables: RetTime.746 <dbl>,
    ## #   Area.747 <dbl>, RetTime.747 <dbl>

    write.csv(dat,"my_results.csv") #save the results 

-   Find the relevant data at
    <https://github.com/RamBarankin/Automating-data-mining-of-lab-data.git>
