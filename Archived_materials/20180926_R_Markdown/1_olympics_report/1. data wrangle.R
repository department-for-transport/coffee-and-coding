#Sue Wallace
#09.09.2018


#Creating a report on the olympics using R markdown
install.packages("DT")
#load libraries----

library(readr) #reading in data and writing out data
library(dplyr) #data wrangle
library(tidyverse) #learn more about the philosophy of tidy verse here
#https://www.tidyverse.org/
library(tidyr) #cleaning a data set

#load data----

olympics <- read_csv("Data/Summer Olympic medallists 1896 to 2008.csv") 

regions <- read_csv("Data/noc_regions.csv")

#data wrangle----

#Let's look at the 2008 Olympics. We can join on the region data as well
#so that we know which country the athletes are from

#I'm also only really interested in a few variables

olympics %>%
  dplyr::left_join(
    x = olympics,  # to this table...
    y = regions,   # ...join this table
    by = "NOC"  # on this key
  ) %>% 
  filter(Edition=="2008") %>%
  select(Sport, Discipline, Athlete, Gender, Event,
         Medal, region) -> olympics_2008

#Which country won the most medals in 2008? Plot into a chart

olympics_2008 %>%
  group_by(region) %>% #group by the region variable
  summarise(count = n()) %>% #summarise the number in the group
  mutate(Percentage = count/sum(count)*100) %>% #create a new % variable
  top_n(10) -> medals #select the top 10 

#We can make a chart from this too

ggplot(data = medals, aes(x = reorder(region, -Percentage), y = Percentage, 
                          label = (round(Percentage,1)))) + 
  geom_col(position = "dodge", fill="lightgoldenrod1") +
  geom_text(position = position_dodge(width = .9), vjust=-0.5) +
  theme_classic() +
  ggtitle("Nation which won the most medals in the 2008 Beijing Olympics") +
  xlab("Nation") +
  ylab("Proportion") -> country


#The USA collected the highest proportion of medals. Let's do a bit more
#analysis on the states

#1. Which gender collected more medals, male or female?

olympics_2008 %>%
  filter(region == "USA") %>%
  group_by(Gender) %>%
  summarise(count=n()) -> usa_gender


ggplot(data = usa_gender, aes(x = reorder(Gender, -count), y = count, 
                          label = count,1)) + 
  geom_col(position = "dodge", fill="lightgoldenrod1") +
  geom_text(position = position_dodge(width = .9), vjust=-0.5) +
  theme_classic() +
  ggtitle("Split of medals between men and women") +
  xlab("Nation") +
  ylab("Count of medals") -> gender

#2. In which event was the most medals won?

olympics_2008 %>%
  filter (region == "USA") %>%
  group_by(Discipline) %>%
  summarise(count=n()) %>%
  mutate(Percentage=count/sum(count)*100) %>%
  top_n(15) -> discipline

ggplot(data = discipline, aes(x = reorder(Discipline, -Percentage), 
                              y = Percentage, 
                          label = (round(Percentage,1)))) + 
  geom_col(position = "dodge", fill="lightgoldenrod1") +
  geom_text(position = position_dodge(width = .9), vjust=-0.5) +
  theme_classic() +
  ggtitle("Which dicipline brought home the most medals for the USA") +
  xlab("Discipline") +
  ylab("Proportion") -> discipline_chart


