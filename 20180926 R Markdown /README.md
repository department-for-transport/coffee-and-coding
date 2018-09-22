# Coffee and Coding: R Markdown

### There are three projects within the file, each of which give a different example of how Rmarkdown can be used. If you are new to R Markdown then review the projects in this order:

1. olympics_report
2. olympics_letters
3. police_shooting_gh

### The first example 'olympics_report' highlights how reporducable reports can be generated in R using ggplot. 
### The second example 'olympics_letters' uses a loop to generate multiple individual letters.
### Finally the third example 'police_shooting' demonstrates the use of flexdashboard and crosstalk to create an interactive html dashbaord


### 3. police_shooting_gh
Creating an interactive html dashboard using crosstalk which details police shootings in the United States between 2015 and 2018.

The Markdown script can be used to create a html dashboard containing summary which details a map powered by leaflet as well as plots generated ggplot2. 

[Crosstalk](https://rstudio.github.io/crosstalk/) developed by [Joe Cheng](https://twitter.com/jcheng?lang=en) extends html widgets with interactivity using sliders, radio buttons and filters. 

## Getting Started

You can clone this repo by typing the following into the command line:
```
git clone https://github.com/mrmoleje/fatal-force-with-crosstalk
```
## Pre-requisites

In order to run this you'll need R Studio installed, as well as the following libraries: dplyr, leaflet, DT, crosstalk, RColorBrewer , readr, ggplot2.

## Data

The data used here is taken from [the Washington Post: Fatal Force](https://www.washingtonpost.com/graphics/2018/national/police-shootings-2018/?noredirect=on&utm_term=.062fe8256817#comments) website which details police shootings in the US from 2015-2018. These data were last updated on August 30th 2018.

The methodology for the data collection can be viewed [here](https://www.washingtonpost.com/national/how-the-washington-post-is-examining-police-shootings-in-the-united-states/2016/07/07/d9c52238-43ad-11e6-8856-f26de2537a9d_story.html?utm_term=.6b7c929d9fbf).

In the aftermath of various racially charged police shootings in 2016 the FBI stated that it would aim to collect more data on police shootings. 

Ethnicity and population statistics are taken from the [Statistical Atlas](https://statisticalatlas.com/United-States/Race-and-Ethnicity) website as at September 16th 2018.

This dashboard was developed on 16th September 2018, and therefor is a snapshot of the data as at that period Any police shootings that occur after 16th September 2018 are not included in this dashboard. 

Geographical information donates the city that the shooting took place, but not the exact location. Some 403 shootings had incomplete location data. 

Note that are there is only three full years' worth of data within this analysis that is it difficult to draw conclusions on trends over time. 

## Acknowledgments

Thanks to [Matt Dray](https://github.com/matt-dray/earl18-crosstalk) for the really great presentation at the London Earl Conference. 
