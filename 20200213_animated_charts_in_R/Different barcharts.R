###Coffee and Coding presentation, February 2020
###Lucy Charlton at ORR


####Creating bar charts

library(readxl) ###loading in excel
library(scales) ### percentage function
library(ggplot2) ###drawing graphs
library(dplyr) ### manipulate data
library(gganimate) ###animated graphs
library(data.table) ##create data table

### this data comes from https://dataportal.orr.gov.uk/media/1669/time-series-of-estimates-of-station-usage-1997-98-to-2018-19.xlsx
### load in data for all stations
allyears <- read_excel("Time series.xlsx")

###pivot data to convert rows to columns
pivotyears<- allyears %>% 
  tidyr::pivot_longer(
    cols = starts_with("20"), 
    names_to = "Year", 
    values_to = "Passengers", 
    names_prefix = "Year_", 
    values_drop_na = TRUE)

###drop unneeded variables
pivotyears<- subset(pivotyears, select = -c(NLC, TLC))

##filter data for London Bridge station only
LB<- pivotyears %>% filter(`Station Name`=="London Bridge")

###create static bar chart, Barchart 1 in slides
LBgraph<- ggplot(LB, aes(Year, Passengers, fill=as.factor(Passengers))) +
  geom_bar(stat="identity") +
  theme_minimal() + scale_y_continuous(labels=comma)+
  theme(
    panel.grid = element_blank(),
    panel.grid.major.y = element_line(color = "white"),
    panel.ontop = TRUE,
    legend.position = "none"
  )

###add in nice colours
barchart1<- LBgraph+scale_fill_brewer(palette="Set3")

###look at barchart1 
barchart1


####now to animate graph! Take the static barchart and add on transition states, so each year will be revealed.
barchart2<- LBgraph + transition_states(Year, wrap = FALSE) +
  shadow_trail()+ scale_fill_brewer(palette="Set3")

####look at barchart2 (this will take time to render)
barchart2

###save as gif, this saves the last animated graph created.
anim_save("barchart2.gif")

###Now let's customise the animation a bit and add in enter grow and fade.
barchart3<- LBgraph +scale_fill_brewer(palette="Set3")+ transition_states(Year, wrap = FALSE) +
  shadow_mark()+
  enter_grow() +
  enter_fade()

####look at barchart3 (this will take time to render)
barchart3

###save as gif
anim_save("barchart3.gif")

#Create colour change barchart, need the data in a datatable
dt<-data.table(LB)

###Add number to each row
dt$time <- seq.int(nrow(dt))



#number of frames per bar, you can change this to whatever number you like
n_frames_per_bar = 6
#create sequence per time (to imitate the bar growing from ground)
split_dt = split(dt, dt$time)
split_dt_fill = lapply(split_dt, function(dti) {
  #create sequence of length n per bar for animation
  data.table(time=dti$time, x=seq(1, dti$Passengers, length.out = n_frames_per_bar))
})
dt_fill = rbindlist(split_dt_fill)

#id each row as its own frame
dt_fill[,frame := 1:.N]

#once a bar is grown it needs to stay there
#fill in historical bars at full height in future time periods
split_dt_fill2 = split(dt_fill, dt_fill$time)
split_dt_fill2_backfill = lapply(split_dt_fill2, function(dti){
  #get time i
  time_i = unique(dti$time)
  #make bar for time i a different color
  dti[,fill := "time i"]
  #backfill bar heights if there is history to fill in
  if (time_i > 1) {
    #get max bar height for all historical bars
    backfill_dt = dt_fill[time < time_i,][order(-frame), .SD[1], by=time][,.(time,x)]
    #create a row of max height for each frame in time i
    split_backfill_dt = split(backfill_dt, backfill_dt$time)
    split_backfill_dt = lapply(split_backfill_dt, function(dtj){
      data.table(time=dtj$time, x=dtj$x, frame=dti$frame)
    })
    backfill_dt = rbindlist(split_backfill_dt)
    #label fill group for coloring bars
    backfill_dt[,fill := "historical"]
    
    out = rbind(dti, backfill_dt)
  } else {
    out = dti
  }
  
  out
})
plot_dt = rbindlist(split_dt_fill2_backfill)

###need to replace numbers with year
plot_dt<-mutate(plot_dt,year=
                  ifelse(time==1, "2008-09",
                         ifelse(time==2,"2009-10",
                                ifelse(time==3, "2010-11",
                                       ifelse(time==4, "2011-12",
                                              ifelse(time==5,"2012-13",
                                                     ifelse(time==6, "2013-14",
                                                            ifelse(time==7,"2014-15",
                                                                   ifelse(time==8, "2015-16",
                                                                          ifelse(time==9, "2016-17",
                                                                                 ifelse(time==10, "2017-18",
                                                                                        ifelse(time==11, "2018-19",NA))))))))))))


#plot graph
barchart4 = ggplot(plot_dt, aes(x=year, y=x, frame=frame, fill=fill)) +
  geom_bar(stat="identity", position = "identity") +
  scale_fill_manual(values=c("#00476B", "#731472")) +
  scale_y_continuous(labels=scales::comma)+
  guides(fill=FALSE) +
  labs(x="Year", y="", title="London Bridge entries and exits")+theme_minimal()+
  theme(
    panel.grid = element_blank(),
    panel.grid.major.y = element_line(color = "white"),
    panel.ontop = TRUE,
    legend.position = "none",
  axis.text.x = element_text(size = 10, angle = 45, hjust = 1))

###look at static barchart4
barchart4

###create animated version by adding transition states
barchart5<- barchart4+transition_states(
  frame,
  transition_length = 1,
  state_length = 1
) 
###customise the frames, speed,endpause and size of animation

animate(barchart5,nframes=100, fps=10,end_pause=25, width=700, height=541)
animate

anim_save("barchart5.gif")
