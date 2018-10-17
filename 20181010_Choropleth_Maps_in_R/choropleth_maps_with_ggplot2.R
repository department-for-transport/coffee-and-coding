#Choropleth Maps with ggplot2
#Isi Avbulimen
#August 2018

# Load libraries we'll be using
library(readr) # for reading and writing CSV files
library(dplyr) # for working with data
library(broom) # summarises data into a tibble

# Spatial libraries
library(rgdal) # Reprojects data between co-ordinate systems (e.g. lat/long to BNG)
library(rgeos) # allows spatial overlay

# Other libraries you will need
library(classInt) # defines intervals for data sets
library(RColorBrewer) # defines colour palettes
library(ggplot2) # for plotting the map!
library(viridis) # for colour palettes

# Step 1 - load in shapefiles #-----------------------------

# Load Local Authority shapefiles
# notice we don't include the file extension
LAs <- rgdal::readOGR("Shapefiles","England_LAUA_2016") 

# it loads in as a large spatial polygons data frame

# Plot to see what it looks like
plot(LAs)

# Step 2 - load in data #-----------------------------------

# load in dummy data
dummy <- read_csv("Data/LA_dummy_data.csv")

# Step 3 - convert shapefile and join to data #-----------------------------------------------

# Next we need to convert the Spatial Polygons data frame into a ggplot2-compatible data frame
# region is the variable we are using to split up the regions
tidy_LAs <- broom::tidy(LAs, region = "LAD16CD")


# Next we join our data with the shapefile
map_data <- tidy_LAs %>% 
  left_join(dummy, by = c("id" = "LA_Code"))


# Step 4 - plot the map #---------------------------------------------------------

# we're plotting the latitude against the longitude and then colouring the map 
# by the Percentage variable
ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, fill = Percentage), 
               col = "black")

# the map looks a bit distorted. We can fix this by using coord_equal() to 
# force a 1:1 aspect ratio
ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, fill = Percentage), 
               col = "black") + coord_equal()

# good aspect ratio now
# but we have a horrible grey background and axes that we don't really want 
# can use a theme_minimal() to get rid of a few things

ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, fill = Percentage), 
               col = "black") +
  coord_equal()+
  theme_minimal()

# so we can use the theme() function to set these things to blank

ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, fill = Percentage), 
               col = "black") +
  coord_equal()+
  theme(panel.background = element_blank(), # get rid of grey background
        axis.line = element_blank(), # get rid of axes lines
        axis.title = element_blank(), # get rid of axes labels
        axis.text = element_blank(), # get rid of the text
        axis.ticks = element_blank()) # get rid of the tick marks

# there are many elements we can use within the theme function
# so that we don't have to call them each time we produce a map, we can create a function
# this one is based on the built in theme_minimal()
theme_map <- 
  theme_minimal() +
    theme(
      text = element_text(family = "sans"), # Arial font
      axis.line = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank(),
      panel.grid = element_blank(),
      plot.background = element_blank(), 
      panel.background = element_blank(), 
      legend.background = element_blank(),
      panel.border = element_blank()
    )

ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, fill = Percentage), 
               col = "black") +
  coord_equal()+
  theme_map

# Step 5 - customise breaks #-----------------------------------

# now we have a good looking map
# however the scale isn't very clear
# we can split the scale up to into discrete categories using the cut_number() 
# function in ggplot2
# cut_number() splits a numeric vector into intervals containing equal number of points

ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, fill = cut_number(Percentage, 5)), 
               col = "black") +
  coord_equal()+
  theme_map

# we can select our breaks using the classIntervals() function from the classInt package

# set your desired number of breaks e.g. n=5
# use your preferred method to create the intervals i.e.
# "fixed", "sd", "equal", "pretty", "quantile", "kmeans", "hclust", "bclust", "fisher", or "jenks"

#TIP - can type ?classIntervals to see the different methods for creating intervals
?classIntervals

#Here we'll use fisher breaks
jenks_breaks <- classIntervals(dummy$Percentage, n=5, style = "jenks")

# check out the breaks which your choosen interval method has created
jenks_breaks$brks 

# if you want you can compare your interval method to another method or create your own breaks
# equal breaks
equal_breaks <- classIntervals(dummy$Percentage, n=5, style = "equal")

#check out the breaks which you have created
equal_breaks$brks

# Have a closer look distribution of the variable and the breaks you have defined using geom_vline
# this way you can see how much data is falling into each interval for each method
vlines <- data.frame(
  jenks = jenks_breaks$brks,
  equal = equal_breaks$brks
) %>% tidyr::gather("method", "brks", jenks:equal)

ggplot(dummy, aes(x=Percentage))+
  geom_histogram(stat = "bin", binwidth = 10)+
  geom_vline(data=vlines, aes(xintercept=brks, color=method))+
  theme_bw()

# We're going to go ahead and use "jenks" breaks for our map within the `cut()` rather than `cut_number()`:
ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, 
                   fill = cut(x = Percentage, n = 5, breaks = jenks_breaks$brks, 
                              include.lowest = TRUE)), 
               col = "black") +
  coord_equal()+
  theme_map

# Step 6 - Customise category labels #---------------------------------------------------------------

# here I define custom labels 
# I'm taking each of the breaks, rounding them to the nearest whole number and concatenating 
# with "to" and the next break, then removing the last label which would be "n to NA %".

labels <- jenks_breaks$brks %>%
  round(0) %>%
  paste0(" to ", lead(.),"%") %>%
  head(-1)


# now we call our labels in the labels argument within cut()
ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, 
                   fill = cut(x = Percentage, n = 5, breaks = jenks_breaks$brks,
                              labels = labels, include.lowest = TRUE)), 
               col = "black") +
  coord_equal()+
  theme_map

#theme(legend.title = element_blank())


# Step 7 - Colours #----------------------------------------------------

# Two packages we can use to add colour:

# RColorBrewer - package contains colour palettes to visualise your data. 3 categories
# - qualitative palettes - different hues to visualise differences between classes
# - sequential palettes - progress from light to dark (good for interval data)
# - Diverging palettes are composed of darker colors of contrasting hues on the 
# high and low extremes and lighter colors in the middle

# http://moderndata.plot.ly/create-colorful-graphs-in-r-with-rcolorbrewer-and-plotly/

# to see all available palettes
display.brewer.all()

#return information about palettes including whether suitable for those colourblind
brewer.pal.info

# use the function scale_fill_brewer() to call the palette
# can name legend 
ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, 
                   fill = cut(x = Percentage, n = 5, breaks = jenks_breaks$brks,
                              labels = labels, include.lowest = TRUE)), 
               col = "black") +
  coord_equal()+
  theme_map+
  scale_fill_brewer(palette = "Greens", name = "Percentage")


# The viridis package brings to R color scales created by Stéfan van der Walt and 
# Nathaniel Smith for the Python matplotlib library

# Use the color scales in this package to make plots that are pretty, 
# better represent your data, easier to read by those with colorblindness, and 
# print well in grey scale.

# https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html 

# we'll use the function scale_fill_viridis()

ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, 
                   fill = cut(x = Percentage, n = 5, breaks = jenks_breaks$brks,
                              labels = labels, include.lowest = TRUE)), 
               col = "black") +
  coord_equal()+
  theme_map+
  viridis::scale_fill_viridis(option = "magma", discrete = TRUE, name = "Percentage")


# or maybe you don't want to use one of these lovely pre-defined palettes and you
# want to define the colours yourself
# you can do this using scale_fill_manual() and define the colours as your values

dft_colours <- c("#006853", #dark green
                 "#66a498", # green
                 "#d25f15", #orange
                 "#e49f73", #light orange
                 "#c99212") #yellow

ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, 
                   fill = cut(x = Percentage, n = 5, breaks = jenks_breaks$brks,
                              labels = labels, include.lowest = TRUE)), 
               col = "black") +
  coord_equal()+
  theme_map+
  scale_fill_manual(values = dft_colours, name = "Percentage")


# Step 8 - Add titles and captions and other things... #--------------------

# we currently do not know what this map is showing or who produced it
# we can add a title and caption

ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, 
                   fill = cut(x = Percentage, n = 5, breaks = jenks_breaks$brks,
                              labels = labels, include.lowest = TRUE)), 
               col = "black") +
  coord_equal()+
  theme_map+
  scale_fill_manual(values = dft_colours, name = "Percentage")+
  labs(x = NULL, 
       y = NULL, 
       title = "Local Authorities in England", 
       subtitle = "2016 - 2017", 
       caption = "Department for Transport")


# add to the theme to change the style of text
ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, 
                   fill = cut(x = Percentage, n = 5, breaks = jenks_breaks$brks,
                              labels = labels, include.lowest = TRUE)), 
               col = "black") +
  coord_equal()+
  theme_map+
  scale_fill_manual(values = dft_colours, name = "Percentage")+
  labs(x = NULL, 
       y = NULL, 
       title = "Local Authorities in England", 
       subtitle = "2016 - 2017", 
       caption = "Department for Transport")+
  theme(plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 15, face = "italic"),
        plot.caption = element_text(size = 11),
        legend.title = element_text(size = 11),
        legend.text = element_text(size = 11))

#### legend

#change the width and height of the legend categories

ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, 
                   fill = cut(x = Percentage, n = 5, breaks = jenks_breaks$brks,
                              labels = labels, include.lowest = TRUE)), 
               col = "black") +
  coord_equal()+
  theme_map+
  scale_fill_manual(values = dft_colours, name = "Percentage",
                    guide = guide_legend(keyheight = unit(4, units = "mm"),
                                         keywidth = unit(8, units = "mm")))+
  labs(x = NULL, 
       y = NULL, 
       title = "Local Authorities in England", 
       subtitle = "2016 - 2017", 
       caption = "Department for Transport")+
  theme(plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 15, face = "italic"),
        plot.caption = element_text(size = 11),
        legend.title = element_text(size = 11),
        legend.text = element_text(size = 11))


# make it horizontal and put it at the bottom
ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, 
                   fill = cut(x = Percentage, n = 5, breaks = jenks_breaks$brks,
                              labels = labels, include.lowest = TRUE)), 
               col = "black") +
  coord_equal()+
  theme_map+
  scale_fill_manual(values = dft_colours, name = "Percentage",
                    guide = guide_legend(direction = "horizontal"))+
  labs(x = NULL, 
       y = NULL, 
       title = "Local Authorities in England", 
       subtitle = "2016 - 2017", 
       caption = "Department for Transport")+
  theme(plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 15, face = "italic"),
        plot.caption = element_text(size = 11),
        legend.title = element_text(size = 11),
        legend.text = element_text(size = 11),
        legend.position = "bottom")

# change position of legend precisely

dft_map <- ggplot() + 
  geom_polygon(data = map_data, 
               aes(x = long, y = lat, group = group, 
                   fill = cut(x = Percentage, n = 5, breaks = jenks_breaks$brks,
                              labels = labels, include.lowest = TRUE)), 
               col = "black") +
  coord_equal()+
  theme_map+
  scale_fill_manual(values = dft_colours, name = "Percentage",
                    guide = guide_legend(keyheight = unit(4, units = "mm"),
                                         keywidth = unit(8, units = "mm")))+
  labs(x = NULL, 
       y = NULL, 
       title = "Local Authorities in England", 
       subtitle = "2016 - 2017", 
       caption = "Department for Transport")+
  theme(plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 15, face = "italic"),
        plot.caption = element_text(size = 11),
        legend.title = element_text(size = 11),
        legend.text = element_text(size = 11),
        legend.position = c(0.2,0.5))

dft_map


# Can label the local authorities

#summarise data to get mean latitude and mean longitude for each LA


LA_labels <- map_data %>% 
  group_by(Local_Authority) %>% 
  summarise_at(vars(long, lat), mean)

# add the labels using geom_text()
dft_map + geom_text(data=LA_labels, aes(long, lat, label = Local_Authority), size=2, fontface="bold")


# choose individual LAs

LA_labels_selected <- LA_labels %>% 
  filter(Local_Authority %in% c("Manchester", "Shropshire", "York", "County Durham"))

dft_map + geom_text(data=LA_labels_selected, aes(long, lat, label = Local_Authority), size=2, fontface="bold")

# not very visible, so we can turn them into labels

dft_map +
  geom_label(data=LA_labels_selected, aes(long, lat, label = Local_Authority),size=2, fontface="bold")

# can change the transparency
dft_map +
  geom_label(data=LA_labels_selected, aes(long, lat, label = Local_Authority), alpha= 0.7, size=2, fontface="bold")















# cnames.selected <- cnames[cnames$Local_Authority %in% (map_data[map_data$Percentage>40,]$Local_Authority),]

#use filter to get LAs with percentage over 80

# LA_labels_80 <- LA_labels %>% 
#   filter(Local_Authority %in% (map_data[map_data$Percentage > 80,]$Local_Authority))








