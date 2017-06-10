source("chels_fun.R") #load the function
start<-744 #first sample number
end<-747 #last sample number
path <-("Sample data/")
dat <- chels_fun(start,end,path)
dat
write.csv(dat,"sample.csv")
