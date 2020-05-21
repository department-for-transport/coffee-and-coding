###Animated top 10 stations code
###Written by Lucy Charlton, ORR January 2020

###load libraries
library(ggplot2) ###drawing graph
library(dplyr) ###tidy data
library(readxl) ###load in excel
library(gganimate) ###animated graphs
library(extrafont) ###custom fonts

###this loads in the ORR Logo, and saves it as object called l
get_png <- function(filename) {
  grid::rasterGrob(png::readPNG(filename), interpolate = TRUE)
}

l <- get_png("ORR logo.png")


###create custom colour palette with departmental colours

orr_colours<- c(
  "#00A3ED", #bright blue
  "#c67517", #dark yellow
  "#7d314c", #dusty pink
  "#ff0000", #red
  "#c34a1b", #vivid orange
  "#4b5555", #dark grey
  "#205e3b", #emerald green
  "#524E86", #dull purple
  "#007B85", #teal
  "#802200", #maroon
  "#008000", #bright green
  "#731472", #purple
  "#B30838", #bold pink, ORR blue
  "#00476B")

###theme for chart
theme_orr <- theme(
  axis.title.x = element_text(size = 13, colour = "black", margin = margin(t = 10)),
  plot.title = element_text(size = 20, family = "Arial", hjust = 0),
  plot.subtitle = element_text(size = 18, family="Arial", colour = "black", hjust = 0,
                               margin = margin(t = 10)),
  legend.key = element_rect(fill = "white", colour = "white"),
  plot.caption = element_text(size = 18, family="Arial", colour = "black"),
  legend.position = "none", legend.direction = "horizontal",
  legend.title = element_blank(),
  text=element_text(size = 20, family = "Arial"),
  axis.ticks = element_blank(),
  axis.text  = element_blank(),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  panel.background = element_blank(),
  axis.line = element_blank(),
  complete = FALSE,
  ###need to amend plot margin so the passenger numbers labels can fit in. Has a lot of room on left
  plot.margin = margin(0.2,3.2,0.1,6.9, "cm")) 


### load in excel file. This comes from https://dataportal.orr.gov.uk/media/1669/time-series-of-estimates-of-station-usage-1997-98-to-2018-19.xlsx
allyears <- read_excel("Time series.xlsx")

###pivot data, to convert columns to rows
pivotyears<- allyears %>% 
  tidyr::pivot_longer(
    cols = starts_with("20"), 
    names_to = "Year", 
    values_to = "Passengers", 
    names_prefix = "Year_", 
    values_drop_na = TRUE)

###drop unneeded variables
pivotyears<- subset(pivotyears, select = -c(NLC, TLC))

###if you want to filter data, such as only London stations, filter at this stage.


### Order by Year and then Passenger numbers 
pivotyears <- pivotyears[with(pivotyears, order(Year, -Passengers)), ]

# Give each station a rank in each year.
pivotyears$rank <- sapply(1:nrow(pivotyears), 
                          function(i) sum(pivotyears[1:i, c('Year')]==pivotyears$Year[i]))

###filter to only include stations in the top 10
top10<- pivotyears %>% filter(rank<=10)


###format Passengers numbers
top10<- top10 %>% group_by(Year)%>% mutate(
  Value_rel = Passengers/Passengers[rank==1],
  Value_lbl = paste0(" ",formatC(Passengers, format="f", big.mark=",", digits=0))) %>%
  ungroup()

##format to adjust Station Name
top10$Station=top10$"Station Name"

###Create animated chart. The closest state means the year will change in the animation.
animatedchart<- ###load in data 
  ggplot(top10, aes(rank, group = Station, 
                                 fill = as.factor(Station), color = as.factor(Station))) + 
  ####passenger numbers
  geom_tile(aes(y = Passengers/2,
                height = Passengers,
                width = 0.9), alpha = 0.8, color = NA) + 
  ###add station name labels
  geom_text(aes(y = 0, label = paste(Station, " ")), 
            vjust = 0.5, hjust = 1, size=6, fontface=2)+ 
  ###add Passenger numbers
  geom_text(aes(y=Passengers,label = Value_lbl, hjust=0),size=6, fontface =2) +
  ### year at bottom of graph
  geom_text(aes(x=9,y=85000000, label=paste0(Year)), size=14, family="Arial", color = 'black', check_overlap=TRUE)+
  coord_flip(clip = "off", expand = FALSE) +
  ###reverse x and y axis
  scale_x_reverse() +
  guides(color = FALSE, fill = FALSE) + 
  ### add in title and webaddress. \n puts the text on new line
  labs(title='Stations with the most entries and exits: {closest_state} \nTop 10 Great Britain',
       caption='dataportal.orr.gov.uk/station-usage',x = "", y = "") + 
  ###transition by year
  transition_states(Year, transition_length = 4, state_length = 3, wrap=FALSE)+
  ###nice transition
  ease_aes('cubic-in-out')+  
  ###colour scheme
  scale_fill_manual(values=orr_colours)+ 
  theme_orr+ 
  scale_color_manual(values=orr_colours)+ 
  ###smooth entry and exit
  enter_fade() + 
  exit_fade()+
  ###ORR logo
  annotation_custom(l, xmin=-10, xmax=-11, ymin=9000000, ymax=10000000) 
 

###Create Animation. Have added in end pause on most recent year, and created custom size.
anim<-animate(animatedchart, nframes=150, fps=5, end_pause=10, width = 800, height = 600)

###Look at animation, this stage takes some time to render ~15-30 seconds
anim

###save as gif
anim_save("Racingbarchart.gif")



