#This code explores the use of ggplot2 themes in the Environment Statistics publication
#
#which was published here 
#https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/718245/electric-chargepoint-2017-rapid.pdf
#along with the raw dataset in csv form
#https://www.gov.uk/government/statistics/electric-chargepoint-analysis-2017-local-authority-rapids

#THe published dataset is the in the training file so you can run the code easily...

#First load tidyverse - which contains the readr package to read in your data...

library(tidyverse)

df2017 <- read_csv(
  file = "data/electric-chargepoint-2017-rapid-raw-data.csv"
  , col_types = cols(.default = col_guess()
                     , ChargingEvent = col_character()
                     , CPID = col_character()
                     , Connector = col_character()
                     , StartDate = col_date(format = "%d/%m/%Y")
                     , StartTime = col_time(format = "%H:%M:%S")
                     , EndDate = col_date(format = "%d/%m/%Y")
                     , EndTime = col_time(format = "%H:%M:%S")
                     , Energy = col_double()
                     , Price = col_double()
                     , LACode = col_character()
                     , Name = col_character()
                     , PluginDuration = col_double()
  ))

View(df2017)

##Some theme are built up from complete base themes. You can open the hood on 
#these by just typing their name:

theme_classic

#You will see it is made up of theme_bw + amendments

theme_bw 

#All themes are complete so every possible graph spec is accounted for, and theme_classic
#will inherit many of these specs from theme_bw

#some more unusual themes are available in the package
library(ggthemes)

#The first paragraph of this theme_classic formats the font size with base_size,
#so all axes will be size 11. The default font style is Arial

#The details after  %+replace% are the things that are different than theme_classic,
#e.g. no grid lines on the tick marks using panel.grid.major = element_blank(),
#and no minor gridlines in between the tick marks 
# that give ggplot2 it's characteristically "squared" background as a default.
#This is done by passing the argument panel.grid.minor = element_blank(),
#in fact anything you don't want can be passed the argument element_blank()
#to remove it.

#You may need to run the following to allow you to adjust the font type (something to do 
#with the versions we use at DfT)

windowsFonts(Arial = windowsFont("TT Arial")) 

#theme_bw is probably the closest to the DfT format in the ggthemes library.

#Andrew Kelly's theme_dft

theme_dft <- theme(
  axis.text = element_text(size = 10, colour = "black"),
  axis.title.x = element_text(size = 13, colour = "black", margin = margin(t = 10)),
  plot.title = element_text(size = 16, family = "Arial", hjust = 0.5),
  plot.subtitle = element_text(size = 13, colour = "black", hjust = -0.05,
                               margin = margin(t = 10)),
  legend.key = element_rect(fill = "white", colour = "white"),
  legend.position = "bottom", legend.direction = "horizontal",
  legend.title = element_blank(),
  legend.text = element_text(size = 9, family = "Arial"),
  axis.ticks = element_blank(),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  panel.background = element_blank(),
  axis.line.y = element_blank(),
  complete = FALSE) +
  theme(axis.line.x = element_line(size = 0.5, colour = "black"))


#You can create my theme_dft5 by making adjustments to Andrew Kellys theme_dft, e.g.

theme_dft5 <-theme(
  axis.text = element_text(size = 10, colour = "black", face = "bold"),
  axis.title.x = element_text(size = 13, face = "bold", colour = "black",
                              margin = margin(t = 10)),
  plot.title = element_text(size = 13, face = "bold", family = "Arial",
                            hjust = -0.09),
  plot.subtitle = element_text(size = 13, colour = "black", hjust = -0.05,
                               margin = margin(t = 10)),
  legend.key = element_rect(fill = "white", colour = "white"),
  legend.position = c(0.1, 0.85), legend.direction = "vertical",
  legend.title = element_blank(),
  legend.text = element_text(size = 9, family = "Arial", face = "bold"),
  axis.ticks = element_blank(),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  panel.background = element_blank(),
  axis.title.y = element_text(size = 13, face = "bold", colour = "black",
                              margin = margin(t = 10, r = 10), angle = 90),
  axis.line.y = element_blank(),
  axis.line.x = element_line(size = 0.5, colour = "black"),
  complete = FALSE)

#or modifying theme_bw using replace.No need to specify anything you won't be using or don't want
#to change. See https://ggplot2.tidyverse.org/reference/theme.html for a description of
#each arguments

theme_bw_modify <- theme_bw()  %+replace% 
  theme(axis.text = element_text(size = 10, colour = "black", face = "bold")
         , axis.title.x = element_text(size = 13, face = "bold", colour = "black",
                                       margin = margin(t = 10))
         , plot.title = element_text(size = 13, face = "bold", family = "Arial",
                                     hjust = -0.09)
         , plot.subtitle = element_text(size = 13, colour = "black",
                                        hjust = -0.05, margin = margin(t = 10))
         , legend.position = c(0.1, 0.85), legend.direction = "vertical"
         , legend.title = element_blank()
         , legend.text = element_text(size = 9, family = "Arial", face = "bold")
         , axis.title.y = element_text(size = 13, face = "bold", colour = "black"
                                    , margin = margin(t = 10, r = 10), angle = 90)
         , axis.ticks = element_blank()
         , panel.grid.major = element_blank()
         , panel.grid.minor = element_blank()
         , panel.background = element_blank()
         , panel.border = element_blank()
         , axis.line.y = element_blank()
         , axis.line.x = element_line(size = 0.5, colour = "black")
         , complete = FALSE)


#You have to remember to say "complete = FALSE" so it knows you want the other specs
#to be inherited from theme_bw. If you are creating a theme from scratch like Andrew,
#you may still need it if there is an argument not specified. In this case, it will
#retrieve these extra specs from the default in ggplot2

#You can therefore play about by applying various themes, and change the things
#you don't like...

#comparing..

#theme_bw

ggplot(data = df2017, aes(as.numeric(Energy))) + 
  geom_histogram(binwidth = 2.5) +
  xlab("Energy supplied, kWh") + 
  ylab("Frequency") + 
  theme_bw()

#theme_economist

ggplot(data = df2017, aes(as.numeric(Energy))) + 
  geom_histogram(binwidth = 2.5) +
  xlab("Energy supplied, kWh") + 
  ylab("Frequency") +
  theme_economist()

#theme_minimal

ggplot(data = df2017, aes(as.numeric(Energy))) +
  geom_histogram(binwidth = 2.5) +
  xlab("Energy supplied, kWh") +
  ylab("Frequency") +
  theme_minimal()

#theme_dft (Andrew Kelly)

ggplot(data = df2017, aes(as.numeric(Energy))) +
  geom_histogram(binwidth = 2.5) +
  xlab("Energy supplied, kWh") +
  ylab("Frequency") +
  theme_dft

#theme_dft5 (with extra customised specs such as colour fill choice
#, thousand commas on the axes labels etc used in the Chargepoint publication)
# Filtering by pluginduration < 100 for this example.

ggplot(data = df2017 %>% filter(PluginDuration < 100), aes(x = PluginDuration)) +
  geom_histogram(binwidth = 5, colour = "white", fill = "#006853") +
  xlab("Length of plug-in time, mins") + 
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 10)) +
  scale_y_continuous(breaks = seq(0, 8000, 2000), name = "",
                     labels = c("0", "2,000", "4,000", "6,000", "8,000")) +
  ggtitle("Frequency") +
  theme_dft5

#You can then repeatedly re-use your theme as R has saved it as a new object  :-)

#N.B.
# I've filtered to durations < 100 in the "data =" statment 
#This is because the chargepoint data had what you could call a large minority of extreme events
#in this case, people plugging in for weeks and months! but I wanted to focus on typical
#charging behaviour in my publication


#Alternative example of modifying a theme (making only 3 changes) is this one
#for theme_minimal, removing the vertical gridlines 
#and adding a line on the x-axis

theme_minimal_modify <- theme_minimal()  %+replace% 
  theme(panel.grid.major.x = element_blank()
        , panel.grid.minor.x = element_blank()
        , axis.line.x = element_line(size = 0.5, colour = "black")
        , complete = FALSE)

ggplot(data = df2017 %>% filter(PluginDuration < 100), aes(as.numeric(PluginDuration))) +
  geom_histogram(binwidth = 5, colour = "white", fill = "#006853") +
  xlab("Length of plug-in time, mins") +
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 10)) + 
  scale_y_continuous(breaks = seq(0, 12000, 2000), name = ""
                     , labels = c("0","2,000","4,000","6,000", "8,000", 
                                  "10,000", "12,000")) + 
  ggtitle("Frequency") +
  theme_minimal_modify

#things you won't be likely to need but should know:
#arguments to panel refer to the multiple panels that
#you create when using functions like facet_wrap
#or facet grid (that split up your data by a given factor eg. year)
##arguments to strip change the "strips" of text on top of your grids, eg
##grid lines can be set with the grid functions
#e.g. panel.grid.major.x = element_blank() ,
# explicitly set the horizontal lines separately  (or they will disappear too)
#panel.grid.major.y = element_line( size=.1, color="black" ) 


##Some examples of how I used ggplot2 in the chargepoint publication will follow..

##The theme I went with was theme_dft5, after some trial and error!

##First comes a little more analysis...

##I used lubridate package to give me a 'top-of-the-hour' column,

library(lubridate) 

#which is great with dates and times,
#as there was interest in when customers were most likely to plug-in
#For example, an EV plugged in at 12:03 would have "12" in the hour col.
#that follows...
#create top of the hour column...


df2017 <- df2017 %>% mutate(hour = hour(StartTime))

#shiny new hour column added!! scroll to your left :-)

View(df2017)

##now I want a bit more stats...so I use dplyr,
#which is great for manipulating datasets

library(dplyr)

hourly.df.17 <- df2017 %>%
  group_by(hour) %>%
  summarise(median_charge = median(Energy),
            mean_charge = mean(Energy),
            median_plugin = median(PluginDuration),
            mean_plugin = mean(PluginDuration)) %>%
  arrange(median_charge,mean_charge,median_plugin, mean_plugin)

View(hourly.df.17)

#dplyr gives an easy way to do summary stats in tables without sweating over
#a pivot table. Here, I have asked R to create a table
#grouped by hour of plug-in start time. It will then give me 
#each summary stat I ask for, for each hour, and store it in the columns 
#I have asked it to create e.g. mean_charge, median_charge etc.



ggplot(data = hourly.df.17, aes(x = hour, y = (median_plugin))) +
  geom_point(size = 2.5, color = "#006853") +
  geom_line(lwd = 1.1, color = "#006853") +
  theme_dft5 + 
  scale_x_continuous(name = "Hour of plug-in start time, 24 hour clock"
                     , breaks = seq(0, 23, 2)) + 
  scale_y_continuous(name = "", breaks = seq(0, 40, 10), limits = c(0, 40)) + 
  ggtitle("Length of plug-in time, mins")

ggplot(data = hourly.df.17, aes(x = hour, y = (median_charge))) +
  geom_point(size = 2.5, color = "#d25f15") +
  geom_line(lwd = 1.1, color = "#d25f15") +
  theme_dft5 + 
  scale_x_continuous(name = "Hour of plug-in start time, 24 hour clock"
                     , breaks = seq(0, 23, 2)) +
  scale_y_continuous(name = "", breaks = seq(0, 15, 5), limits = c(0, 15)) +
  ggtitle("Median energy supplied, kWh")

#Again, I have specified the way the tickmarks are placed, but 
#used the same theme_dft5 to make my publication consistent.
#Note, order is irrelevant, it doesn't matter how I place the chunks


#I can also add up the number of events
#per hour using the convenient tally function...

Freq.hr17 <- df2017%>%
  group_by(hour) %>%
  tally()
View(Freq.hr17)

##and then plot this with a dft_colour of my choice...

ggplot(Freq.hr17, aes(x = hour, y = n)) + 
  geom_point(size = 2.5, color = "#006853") + 
  geom_line(lwd = 1.1, color = "#006853") + 
  theme_dft5 + 
  scale_x_continuous(name = "Hour of plug-in start time, 24 hour clock"
                     , breaks = seq(0, 23, 2)) + 
  scale_y_continuous(name = "", breaks = seq(0, 10000, 2000)
                     , limits = c(0, 11000)
                     , labels = c("0", "2,000", "4,000", "6,000", "8,000", "10,000")) + 
  ggtitle("Number of charging events")

#It is also possible to put thousand commas on direct labels,
#using the package 

library(scales)

#for example on the horizontal var chart below...

#...I want to look at the number of events,
#but this time I want to compare local authorities in the
#"Name" column of the dataset...

#plot for frequency of events by LA

Freq.schemes17 <- df2017 %>%
  group_by(Name) %>%
  tally()
View(Freq.schemes17)

##Notice I use reorder to put the best performer at the top,
#and geom_bar with stat= "identity" to create a simple bar chart
#my labels go in geom_text, and I have used hjust to put
#the labels where I want them, remembering to add my theme
#for a consistent look. comma(n) tells R I want thousand commas
#on my labels, and fontface = "bold" obviously gives bold font,
#to match the bold font I have already used within the theme

ggplot(Freq.schemes17, aes(x = reorder(Name, n), y = n)) +
  
  geom_bar(stat = "identity", fill ="#006853") + 
  theme_dft5 + 
  coord_flip() +
  geom_text(aes(label = comma(n)), hjust = -0.25, size = 3.5, fontface = "bold") + 
  scale_y_continuous(name = "Number of charging events"
                     , breaks = seq(0, 40000, 10000)
                     , labels = c("0", "10,000", "20,000", "30,000", "40,000")
                     , limits = c(0, 40000)) +
  xlab("")


#Once you have created your shiny lovely new
#plots, you will want them to look just as sharp
#when you import them. If you are using InDesign,
#it is an added bonus that you can specify their size without
#changing their aspect ratio...using the argument for dpi (dots per inch)
#You will find res = 600 will be pretty sharp, but can increase further.
#The more dots per inch, the larger the file size though.

#You can do this using ggsave function:
plot_to_save <- ggplot(data = df2017 %>% filter(PluginDuration < 100), 
                       aes(PluginDuration)) +
  geom_histogram(binwidth = 5, colour = "white", fill = "#006853") +
  xlab("Length of plug-in time, mins") + 
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 10)) +
  scale_y_continuous(breaks = seq(0, 8000, 2000), name = ""
                     , labels = c("0", "2,000", "4,000", "6,000", "8,000")) +
  ggtitle("Frequency") +
  theme_dft5

ggplot2::ggsave("my_pretty_plot.png", plot_to_save, width = 15, height = 9.5, units = "cm")

## If you're working with inDesign you may wish to save as a Vector graphic (svg file) 
# as they do not blur like raster images (based on pixels, link png)
# Gennerally avoid jpg or jpeg as the compression is lossy, meaning quality is lost on save
ggplot2::ggsave("my_pretty_plot.svg", plot_to_save, width = 15, height = 9.5, units = "cm")

