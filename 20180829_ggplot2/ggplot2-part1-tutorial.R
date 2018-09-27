#####################################
# GGPLOT 2 SHOWCASE
#####################################
# install.packages('tidyverse')
library(tidyverse)

# This short file will just explain the general principles of
# ggplot2 and give examples of these elements in use

#-----------------------------------
# What is ggplot2?
#-----------------------------------

# ggplot2 is an R package around making graphics. It operates on the principles
# of a book called the "Grammar of Graphics" by Leland Wilkinson (Springer Series).
# In this book it describes a form of "grammatical rules" for making perceivable
# graphs, or what they call 'graphics', within in distributed computing environment.

# Hadley Wickham in 2005 took these principles implemented it into R with ggplot2.

# Having a grammar of graphics allows us to build graphs using an official syntax. 
# The individual components of each graph are like parts of a well-written sentence. 

# The ggplot2 syntax uses layers as a "linear ordering of phrases" to build graphs 
# "which convey a gnarly network of ideas." Stated simply - the underlying grammar 
# provides a framework for an analyst to build each graph one part at a time in a 
# sequential order (or layers).

# The composition of ggplot2 calls have five parts:

# 1) A data set, and
# 2) The aesthetic mapping ( aes() ), and
# 3) A statistical transformation ( stat= ), or
# 4) A geometric object ( geom_ ), and if needed
# 5) A position adjustment ( position= )

#-----------------------------------
# Part One - A data set
#-----------------------------------

# In calling a ggplot object, we first specify the dataset. Once this is done, we
# don't need to keep recalling it within the same object. We also don't need to 
# specifically define subsets with DATASET$COLUMN or whatever (although you can if
# you want!) 

# Let's load some data. Let's use one of the default R datasets: the MPG dataset
# This is based on a study of the performance of new car models over time.

data(mpg)
load(mpg)

# Let's write our first ggplot object, calling the dataset MPG

ggplot(mpg)
# Hmm. It created a graphic object with nothing in it.

# Well of course! we have told it the dataset, but not what to do with it! But 
#it's a start.

#-----------------------------------
# Part Two - An aesthetic mapping
#-----------------------------------

# Once we have a dataset defined, we now tell it what variables to use, known
# as the 'Aesthetic'. This is done by an AES object

# If you only have one variable, just put one thing in there such as:

ggplot(mpg, aes(x = cty))

# or,

ggplot(mpg, aes(cty)) # without having to explicitly say "x=" ... ggplot2 will just know

# Two variables can be written as 

ggplot(mpg, aes(cty, hwy))

# And two variables, but coloured according to a third variable:

ggplot(mpg,aes(cty, hwy, class))

# We will see how these work in the next part, when we add a GEOMETRY to the chart. Notice
# how running any of these will now put in axes, but no data. Well, we haven't told ggplot2
# HOW we want the data presented!

#-----------------------------------
# Part Three - Geometries
#-----------------------------------

# We have now told ggplot2 what data to use, and what varibles we are going to use.
# Now we tell it what geometrical objects we want to use to represent the data.

# This is done via a GEOM_ object, of which there are lots. A very good "cheat sheet"
# has been written by RStudio: a quick google search should find it.

# Let's stick on our first geometry to examine this MPG data. Let's look at how the 
# HWY variable (highway miles per gallon) is distributed.

ggplot(mpg, aes(hwy)) +
  geom_histogram()

# ggplot2 sees that we only have defined one variable, so knows to make the y axis a count.

# Note the warning message, telling us to "pick better value with binwidth". All of these
# objects have arguments that can be defined within the brackets to tweak the output. Let's 
# try changing the binwidth to 5

ggplot(mpg, aes(hwy)) +
  geom_histogram(binwidth = 5)

# The help files for each geom specify what objects can be placed inside the brackets. There
# are LOTS of options.

# What if we want to also see the frequency polygon?

ggplot(mpg, aes(hwy)) +
  geom_freqpoly(binwidth = 5)

# Looking good. But what if we want both of them ... at the same time?

# Simple! All we need to do is add another geometry (geom_) object, and ggplot2 will plot
# both!

ggplot(mpg, aes(hwy)) +
  geom_histogram(binwidth = 5) +
  geom_freqpoly(binwidth = 5)

# A word of warning: ggplot2 will layer the graphics in order. Watch if we flip the order:

ggplot(mpg, aes(hwy)) +
  geom_freqpoly(binwidth = 5) +
  geom_histogram(binwidth = 5)

# Now the frequency polygon is layered BEHIND the histogram. Use this to your advantage!

# For demonstration, lets now see a two variable plot:

ggplot(mpg, aes(cty, hwy)) +
  geom_point()

# Now we see the city mpg plotted against highway mpg. Looking good... except we have multiple
# points layered over each other. We do have a GEOM_JITTER to slightly displace them to see
# the true distribution better:

ggplot(mpg, aes(cty, hwy)) +
  geom_jitter()

# Nice. Now let's add a line of best fit using GEOM_SMOOTH

ggplot(mpg, aes(cty, hwy)) +
  geom_jitter() +
  geom_smooth()

# oops! it's defaulted to a non parametric version called LOESS, as the warning message says.
# The help file tells us of the METHOD argument to select the regression type:

ggplot(mpg, aes(cty, hwy)) +
  geom_jitter() +
  geom_smooth(method = lm)

# Better! It still gives the confidence interval. We can add an ALPHA argument to remove this.
# Let's also make the line red:

ggplot(mpg, aes(cty, hwy)) +
  geom_jitter() +
  geom_smooth(method = lm, colour = "red", alpha = 0)

# I hope you can see how easy it is to layer things in ggplot2!

# BUT WAIT THERE'S MORE

# What if you are adding multiple geoms... but you want to customise the aesthetic for
# just one of them? Just add an aes() object AS AN ARGUMENT!

ggplot(mpg, aes(hwy, cty)) + 
  geom_point(aes(color = cyl)) +
  geom_smooth(method = lm)

#-----------------------------------
# Part Four - Using STAT_ objects
#-----------------------------------

# STAT_ objects are actually an alternative way to build a layer, instead of GEOM_

ggplot(mpg, aes(cty)) + geom_bar()
ggplot(mpg, aes(cty)) + stat_bin()

# See how similar they are? There are multiple way to achieve the same end. 

# Some thing are better suited for STAT_. A chart can be defined by a mathematical function
# with a STAT_ object

ggplot(data.frame(x = c(-5, 5)), aes(x)) +
  stat_function(fun = dnorm)

# Here we defined a dataset on the fly using data.frame, and then used it to specify a
# STAT_FUNCTION object, with a normal distribution within that data.frame.

# STAT_SUMMARY can be used to compute aggregates of a data set, and is quite flexible.

(g <- ggplot(mpg, aes(class, cty)) + geom_point())

# Let's now summarise the median using a red point:

g + stat_summary(fun.y = "median", colour = "red", size = 5, geom = "point")

# Classy!

#-----------------------------------
# Part Five - Position adjustment
#-----------------------------------

# We saw above how we needed to use GEOM_JITTER to see data points that exactly overlapped
# but what if you had two bar charts?

ggplot(mpg, aes(factor(cyl), fill = factor(drv))) +
  geom_bar()

# Ew! If only we could make them DODGE each other and be side by side...

ggplot(mpg, aes(factor(cyl), fill = factor(drv))) +
  geom_bar(position = "dodge")

# POSITION= objects allow us to specify how to handle layers that overlap. In our example
# of the dot plot, we could also have used POSITION_JITTER() to achieve the same result

ggplot(mpg, aes(cyl, hwy)) +
  geom_point()

# becomes when using a GEOM_JITTER()

ggplot(mpg, aes(cyl, hwy)) +
  geom_jitter()

# and if using POSITION=JITTER

ggplot(mpg, aes(cyl, hwy)) +
  geom_point(position = position_jitter())

# POSITION_JITTER however gives more control:

ggplot(mpg, aes(cyl, hwy)) +
  geom_point(position = position_jitter(width = 0.2, height = 0.1))

# A final position example is when we have overlapping bar charts, and rather than
# putting them side-by-side (dodge) we instead want to fill to 100%

ggplot(mpg, aes(factor(cyl), fill = factor(drv))) +
  geom_bar(position = position_fill())

#-----------------------------------

# So now we have covered the core elements of the grammar. But what about the appearance?

#-----------------------------------
# Changing coordinate systems
#-----------------------------------

# Let's take our bar chart:

ggplot(mpg, aes(factor(cyl), fill = factor(drv))) +
  geom_bar()

# The default coordinate system is Cartesian, but what if we instead wanted to flip the x and y?
# We do this by bolting on a COORD_FLIP() object

ggplot(mpg, aes(factor(cyl), fill = factor(drv))) +
  geom_bar() +
  coord_flip()

# Simple! You can even get wacky and change to polar coordinates

ggplot(mpg, aes(factor(cyl), fill = factor(drv))) +
  geom_bar() +
  coord_polar()

# For obvious reasons, this is best left to when you have suitable data!

#-----------------------------------
# Faceting
#-----------------------------------

# Let's load some new data for median house prices
london <- read_csv(file = "data/lon_median.csv")

# Let's do a simple line chart comparing the top and bottom boroughs
# in 2017. We will use a simple geom_point

ggplot(filter(london, Borough %in% c("Kensington and Chelsea", "Barking and Dagenham")),
       aes(x = year,
           y = median/1000,
           color = Borough)) +
  geom_point()

# Wow that's quite a difference! Let's take a look at all boroughs...

ggplot(london,
       aes(x = year,
           y = median/1000,
           color = Borough)) +
  geom_line()

# What a mess. An interesting mess... but still a mess.
# If only there were some way to see each borough on their own

ggplot(london,
       aes(x = year,
           y = median/1000)) +
  geom_line() +
  facet_wrap(~ Borough, ncol = 5)

# Much better! They all keep the same vertical axis scale, so they can be compared easily.

#-----------------------------------
# Labels
#-----------------------------------

# Chaging axes labels and adding a title is simple. Just bolt them on!
ggplot(filter(london, Borough %in% c("Kensington and Chelsea", "Barking and Dagenham")),
       aes(x = year,
           y = median/1000,
           color = Borough)) +
  geom_point() +
  xlab("Year") +
  ylab("Median house price (thousand pounds)") +
  ggtitle("Median house prices over time")

# Or in one LABS object:
ggplot(filter(london, Borough %in% c("Kensington and Chelsea", "Barking and Dagenham")),
       aes(x = year,
           y = median/1000,
           color = Borough)) +
  geom_point() +
  labs(x = "Year",
       y = "Median house price (thousand pounds)",
       title = "Median house prices over time")

#-----------------------------------
# Themes
#-----------------------------------

# Themes is where the appearance really changes. This is where you can change axis
# tick mark frequency, background colours, grid lines, fonts ... everything.

# As you can imagine, the number of arguments for a THEME object is immense. The
# help file is your friend!

# The first thing you can do is try bolting-on one of the detault preset themes:
ggplot(filter(london, Borough %in% c("Kensington and Chelsea", "Barking and Dagenham")),
       aes(x = year,
           y = median/1000,
           color = Borough)) +
  geom_point() +
  labs(x = "Year",
       y = "Median house price (thousand pounds)",
       title = "Median house prices over time") +
  theme_bw()

# Looking better already! How about:
ggplot(filter(london, Borough %in% c("Kensington and Chelsea", "Barking and Dagenham")),
       aes(x = year,
           y = median/1000,
           color = Borough)) +
  geom_point() +
  labs(x = "Year",
       y = "Median house price (thousand pounds)",
       title = "Median house prices over time") +
  theme_classic()

# Looking closer to DfT standard already! The package "ggthemes" gives more of these.

# THEME is great however for fine tuning. Here is an example: Let's make some data:
liquid_data <- tibble(
  years = c(rep(seq(2007, 2016, 1), 4))
  , cargo = c(rep("Crude Oil", 10), rep("Liquefied Gas", 10), rep("Oil Products", 10)
              , rep("Other Liquid", 10))
  , tonnage = c(140, 132, 123, 118, 113, 105, 93, 89, 91, 87, 8, 7, 13, 21, 24, 16
                , 12, 13, 15, 13, 86, 87, 79, 79, 81, 79, 82, 74, 78, 78, 15, 13
                , 12, 13, 12, 11, 10, 11, 10, 12)
)

ggplot(liquid_data, aes(x = years, y = tonnage, colour = cargo)) +
  geom_line(size = 1.5) +
  scale_x_continuous(breaks = seq(2007, 2016, 1)) +
  scale_y_continuous(limits = c(0, 160), breaks = seq(0, 160, 20)) +
  labs(title = "Liquid Bulk Freight, 2007 to 2016",
       subtitle = "Tonnage (Million Gross Tonnes)") +
  labs(x = "Year", y = "")

# Let's get tweaking! First I define a colour palette as a vector:

dft_colour <- c(rgb(0,104/255,83/255), rgb(102/255,164/255,152/255)
                , rgb(210/255,95/255,21/255), rgb(228/255,159/255,115/255)
                , rgb(201/255,146/255,18/255),rgb(233/255,211/255,160/255)
                , rgb(0,153/255,169/255), rgb(153/255,214/255,221/255))

# Now I get freaky with the THEME

ggplot(liquid_data, aes(x= years, y = tonnage, colour = cargo)) +
  geom_line(size = 1.5) +
  scale_x_continuous(breaks = seq(2007, 2016, 1)) +
  scale_y_continuous(limits = c(0, 160), breaks = seq(0, 160, 20)) +
  labs(title = "Liquid Bulk Freight, 2007 to 2016",
       subtitle = "Tonnage (Million Gross Tonnes)") +
  labs(x = "Year", y = "") +
  scale_colour_manual(values = dft_colour) +
  theme(axis.text = element_text(size = 10, colour = "black"),
        axis.title.x = element_text(size = 13
                                    , colour = "black"
                                    , margin = margin(t = 10)),
        plot.title = element_text(size = 16, family = "Arial", hjust = 0.5),
        plot.subtitle = element_text(size = 13
                                     , colour = "black"
                                     , hjust = -0.05
                                     , margin = margin(t = 10)),
        legend.key = element_rect(fill = "white", colour = "white"),
        legend.position = "bottom", legend.direction = "horizontal",
        legend.title = element_blank(),
        legend.text = element_text(size = 10, family = "Arial"),
        axis.ticks = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line.y = element_blank(),
        complete = FALSE) +
  theme(axis.line.x = element_line(size = 0.5, colour = "black"))

# You can even save this theme as an object and call it time and time again:

theme_dft <- theme(
  axis.text = element_text(size = 10, colour = "black"),
  axis.title.x = element_text(size = 13, colour = "black", margin = margin(t = 10)),
  plot.title = element_text(size = 16, family = "Arial", hjust = 0.5),
  plot.subtitle = element_text(size = 13, colour = "black", hjust = -0.05
                               , margin = margin(t = 10)),
  legend.key = element_rect(fill = "white", colour = "white"),
  legend.position = "bottom", legend.direction = "horizontal",
  legend.title = element_blank(),
  legend.text = element_text(size = 9, family = "Arial"),
  axis.ticks = element_blank(),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  panel.background = element_blank(),
  panel.border = element_blank(),
  axis.line.y = element_blank(),
  complete=TRUE) +
  theme(axis.line.x = element_line(size = 0.5, colour = "black"))

#apply saved theme to plot
ggplot(liquid_data,aes(x = years, y = tonnage, colour = cargo)) +
  geom_line(size = 1.5) +
  scale_x_continuous(breaks = seq(2007, 2016, 1)) +
  scale_y_continuous(limits = c(0, 160), breaks = seq(0, 160, 20)) +
  labs(title = "Liquid Bulk Freight, 2007 to 2016",
       subtitle = "Tonnage (Million Gross Tonnes)") +
  labs(x = "Year", y = "") +
  scale_colour_manual(values = dft_colour) +
  theme_dft

#------------------------------
# Now for one I made earlier!
#------------------------------

# Let's produce a chart of 'Corruption Perception Index' versus 'Human Development Index'
# from data make public by The Economist


# Load up the data
# or use read_csv from readr package (tidyverse)
dat <- read.csv("data/EconomistData.csv")

# Ordering the regions the way we want from the start
dat$Region <- factor(dat$Region,
                     levels = c("EU W. Europe",
                                "Americas",
                                "Asia Pacific",
                                "East EU Cemt Asia",
                                "MENA",
                                "SSA"),
                     labels = c("OECD",
                                "Americas",
                                "Asia &\nOceania",
                                "Central &\nEastern Europe",
                                "Middle East &\nnorth Africa",
                                "Sub-Saharan\nAfrica"))

# Let's just do a standard geom_point to see how things look

pc1 <- ggplot(dat, aes(x = CPI, y = HDI, color = Region))
pc1 + geom_point()

# OK, we see a general trend at least. Let's add a trend line
# That pattern looks like a log relation to me, so lets go with y~x+log(x)
# Let's plot the line FIRST so that this is the "bottom layer"

pc2 <- pc1 +
  geom_smooth(mapping = aes(linetype = "r2"),
              method = "lm",
              formula = y ~ x + log(x), se = FALSE,
              color = "red")
pc2 + geom_point()

# Let's go with open circles by adding a "shape" term to the geom_point

(pc3<-pc2 +
  geom_point(shape = 1, size = 2, stroke=1.25))


# Let's now try and add some labels. Obviously we can't label all... let's pick some as a vector

pointsToLabel <- c("Russia", "Venezuela", "Iraq", "Myanmar", "Sudan",
                   "Afghanistan", "Congo", "Greece", "Argentina", "Brazil",
                   "India", "Italy", "China", "South Africa", "Spane",
                   "Botswana", "Cape Verde", "Bhutan", "Rwanda", "France",
                   "United States", "Germany", "Britain", "Barbados", "Norway", "Japan",
                   "New Zealand", "Singapore")

# These can now be applied using a geom_text()

(pc4 <- pc3 +
    geom_text(aes(label = Country),
              color = "gray20",
              data = subset(dat, Country %in% pointsToLabel)))

# Looking a little crowded. Let's use the ggrepel package to try and tidy these up
#install.packages('ggrepel')
library(ggrepel)
pc4 <- pc3 +
    geom_text_repel(aes(label = Country),
                    color = "gray20",
                    data = subset(dat, Country %in% pointsToLabel),
                    force = 50)
pc4

# A little better.
# Let's now label the axes and the chart and tidy up a bit
library(grid)
pc5 <- pc4 +
    scale_x_continuous(name = "Corruption Perceptions Index, 2011 (10=least corrupt)",
                       limits = c(.9, 10.5),
                       breaks = 1:10) +
    scale_y_continuous(name = "Human Development Index, 2011 (1=Best)",
                       limits = c(0.2, 1.0),
                       breaks = seq(0.2, 1.0, by = 0.1)) +
    scale_color_manual(name = "",
                       values = c("#24576D",
                                  "#099DD7",
                                  "#28AADC",
                                  "#248E84",
                                  "#F2583F",
                                  "#96503F")) +
    ggtitle("Corruption and Human development")
pc5

# Nearly there, but the default theme is painful. Let's tweak the theme:
pc6 <- pc5 +
    theme_bw() +
    theme(panel.border = element_blank(),
          panel.grid = element_blank(),
          panel.grid.major.y = element_line(color = "gray"),
          axis.line.x = element_line(color = "gray"),
          axis.text = element_text(face = "italic"),
          legend.position = "top",
          legend.direction = "horizontal",
          legend.box = "horizontal",
          legend.text = element_text(size = 12),
          plot.title = element_text(size = 16, face = "bold"))
pc6

# Nice! Now let's add the R^2 to that graph and be done.
mR2 <- summary(lm(HDI ~ CPI + log(CPI), data = dat))$r.squared
mR2 <- paste0(format(mR2, digits = 2), "%")
pc7 <- pc6 +
    scale_linetype(name = "",
                  breaks = "r2",
                  labels = list(bquote(R^2 == .(mR2))),
                  guide = guide_legend(override.aes = list(linetype = 1, size = 2, 
                                                           color = "red")))
pc7


