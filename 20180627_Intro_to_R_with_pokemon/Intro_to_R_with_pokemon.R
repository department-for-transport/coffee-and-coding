#this script has been taken from section 5-8 of the online tutorial 
#'Beginner R and RStudio training' by Matt Dray (DfE)
#at the following web address
#https://matt-dray.github.io/beginner-r-feat-pkmn/#5_get_data_in_and_look_at_it
  
#install required packages if not already installed
#install.packages('tidyverse') #note quotes

#load required packages, note no quotes
library(tidyverse)
#tidyverse is a collection of packages, including, but not limited to
#dplyr, ggplot2, readr, stringr, tibble, lubridate, stringi, tidyr

#throughout this I have tried to be explicit about 
#which package each funciton comes from
#all the funciton calls are in the form
#package_name::function_name()
#however, if function name is unique, within the packages loaded
#then you don't need to declare the package_name 
#and can just use the function_name

#to find out more about a function simply type ?function_name, eg
?read_csv
#or explicitly
?readr::read_csv

#read in data and asign to the newly created object 'pokemon'
pokemon <- readr::read_csv(file = "data/pokemon_go_captures.csv")

#data inspection
tibble::glimpse(pokemon)

#print to console
base::print(pokemon)

#view data
View(pokemon) # opens tab with data, note the capital 'V'
utils::View(pokemon) # opens a popup with data, navigate with arrow keys

#summary {base} stats
base::summary(pokemon)
#gives some quick stats on the numeric columns


# dplyr functions ---------------------------------------------------------

#dplyr::select
# save as an object for later
pokemon_hp <- dplyr::select( 
  pokemon,  # the first argument is always the data
  hit_points,  # the other arguments are column names you want to keep
  species
)  

# note the column names are unquoted, if you have a promblematic column name 
# that has spaces or starts with a number you can encase it in back ticks eg
# `101 this is a silly column name`
print(pokemon_hp)

#select by dropping columns
dplyr::select(
  pokemon,  # data frame first
  -hit_points, -combat_power, -fast_attack, -weight_bin  # columns to drop
)

#select columns with similar names
dplyr::select(pokemon, starts_with("weight"))

dplyr::select(pokemon, contains("bin"))

#see 
?dplyr::select_helpers

# CHALLENGE!
#   Create an object called my_selection that uses the select() function 
# to select from pokemon the species column and any columns that ends  
# with "attack"






# A solution
# my_selection <- dplyr::select(pokemon
#                               , species
#                               , ends_with("attack"))


#dplyr::filter
#logical operators
# 
# ==      equals
# !=      not equals
# %in%    match to several things listed with c()
# >, >=   greater than (or equal to)
# <, <=   less than (or equal to)
# &       and
# |       or

#filter on a single species
dplyr::filter(pokemon, species == "jigglypuff")

#now everything except for one species
dplyr::filter(pokemon, species != "pidgey")  # not equal to

#filter on three species
dplyr::filter(
  pokemon,
  species %in% c("staryu", "psyduck", "charmander")
)

#we can work with numbers too
dplyr::filter(
  pokemon
  , combat_power > 900 & combat_power < 1000 # two conditions
  , hit_points < 100  
) # note the '&'

# CHALLENGE!
#   
#Filter the pokemon dataframe to include rows that:
#   
# are the species “abra”, “chansey”, or “bellsprout”
# and have between 100 and 500 combat_power
# and less than 100 hit_points

# A solution
# dplyr::filter(
#   pokemon
#   , species %in% c("abra", "chansey", "bellsprout")
#   , combat_power > 100 & combat_power < 500
#   , hit_points < 100
# )



#dplyr::mutate
# we're going to subset by columns first
pokemon_power_hp <- dplyr::select(  # create new object subsetting data set
  pokemon,  # data
  species, combat_power, hit_points  # columns to keep
)

# now to mutate with some extra information
dplyr::mutate(
  pokemon_power_hp  # our new, subsetted data frame
  , power_index = combat_power * hit_points  # new column from old ones
  , caught = 1  # new column will fill entirely with number
  , area = "kanto"  # will fill entirely with this text 
)

#the vector values used in mutate() must be either length 1 (they then 
#get recycled) or have the same length as the number of rows. 
#if you want to recycle values then you need to use base R
#and the vector length needs to divisible by the total data length
pokemon_power_hp$new_column_name <- 1:3


# 
# You can mutate a little more easily with an if_else() statement:
dplyr::mutate(
  pokemon_hp,
  common = if_else(
    condition = species %in% c(  # if this condition is met...
      "pidgey", "rattata", "drowzee", 
      "spearow", "magikarp", "weedle", 
      "staryu", "psyduck", "eevee"
    ),
    true = "yes",  # ...fill column with this string
    false = "no"  # ...otherwise fill it with this string
  )
)

# And we can get more nuanced by using a case_when() statement 
# (you may have seen this in SQL). This prevents us writing nested 
# if_else() statements to specify multiple conditions.

pokemon_hp_common <- dplyr::mutate(
  pokemon_hp,  # data
  common = dplyr::case_when(
    species %in% c("pidgey", "rattata", "drowzee") ~ "very_common"
    , species == "spearow" ~ "pretty_common"
    , species %in% c("magikarp", "weedle", "staryu", "psyduck") ~ "common"
    , species == "eevee" ~ "less_common"
    , TRUE ~ "no" #else = "no"
  )
)
# 
# CHALLENGE!
# Create a new dataframe object that takes the pokemon data and adds a 
# column containing Pokemon body-mass index (BMI).
# 
# Hint: BMI is weight over height squared (you can square a number by 
# writing ^2 after it).
# 
# Now use a case_when() to categorise Pokemon:
#   
# Underweight = <18.5
# Normal weight = 18.5–24.9
# Overweight = 25–29.9
# Obesity = BMI of 30 or greater
# Note that these are BMI groups for humans. 

# A solution
pokemon_bmi <- pokemon %>%
  dplyr::mutate(
    bmi = weight_kg / (height_m ^ 2)
    , bmi_bin = dplyr::case_when(
      bmi < 18.5 ~ "underweight"
      , bmi >= 18.5 & bmi < 25 ~ "normalweight"
      , bmi >= 25 & bmi < 30 ~ "overweight"
      , bmi >= 30 ~ "obese"
      #, TRUE ~ "no" # optional, here we have exhausted all the possibilities
    )
  )


#dplyr::arrange
dplyr::arrange(
  pokemon,  # again, data first
  height_m  # column to order by, default is ascending
)

#And in reverse order (tallest first):
dplyr::arrange(pokemon, desc(height_m))  # descending
# 
# CHALLENGE!
# What happens if you arrange by a column containing characters rather 
# than numbers? For example, the species column.

# A solution
# dplyr::arrange(pokemon, species)

#dplyr::join
# 
# Again, another verb that mirrors what you can find in SQL. There are 
# several types of join, but we’re going to focus on the most common one:
# the left_join(). This joins information from one table – x – to 
# another – y – by some key matching variable of our choice.
# 
# Let’s start by reading in a lookup table that provides some extra 
# infomration about our species.

pokedex <- readr::read_csv("data/pokedex_simple.csv")
tibble::glimpse(pokedex)  # let's inspect its contents

# Now we’re going to join this new data to our pokemon data. The key 
# or matching these in the species column, which exists in both datasets.

pokemon_join <- dplyr::left_join(
  x = pokemon,  # to this table...
  y = pokedex,   # ...join this table
  by = "species"  # on this key
)

tibble::glimpse(pokemon_join)
# 
# CHALLENGE!
# Try right_join() instead of left_join(). What happens? And what 
# about  anti_join()?

# Other verbs
# This document does not contain an exhaustive list of other functions 
# within the same family as select(), filter(), mutate(), arrange() and
# *_join(). There are other functions that will be useful for your work 
# and other ways of manipulating your data. For example, the stringr 
# package helps with dealing with data in strings (text, for example).
# 
# Pipes %>% 
# Alright great, we’ve seen how to manipulate our dataframe a bit. But 
# we’ve been doing it one discrete step at a time, so your script might 
# end up looking something like this:

pokemon <- readr::read_csv(file = "data/pokemon_go_captures.csv")

pokemon_select <- dplyr::select(pokemon, -height_bin, -weight_bin)

pokemon_filter <- dplyr::filter(pokemon_select, weight_kg > 15)

pokemon_mutate <- dplyr::mutate(pokemon_filter, organism = "pokemon")

# In other words, you might end up creating lots of intermediate 
# variables and cluttering up your workspace and filling up memory.
# 
# You could do all this in one step by nesting each function inside 
# the others, but that would be super messy and hard to read. Instead 
# we’re going to ‘pipe’ data from one function to the next. The pipe 
# operator – %>% – says ‘take what’s on the left and pass it through 
# to the next function’.
# 
# So you can do it all in one step:
  
pokemon_piped <- readr::read_csv(file = "data/pokemon_go_captures.csv") %>% 
  dplyr::select(-height_bin, -weight_bin) %>% 
  dplyr::filter(weight_kg > 15) %>% 
  dplyr::mutate(organism = "pokemon")

tibble::glimpse(pokemon_piped)

# This reads as:
# for the object named pokemon_piped, assign (<-) the contents of a 
# CSV file read with readr::read_csv()
# then select out some columns
# then filter on a variable
# then add a column
# See how this is like a recipe?
#   
# Did you notice something? We didn’t have to keep calling the dataframe 
# object in each function call. For example, we used 
# dplyr::filter(weight_kg > 15) rather than 
# dplyr::filter(pokemon, weight_kg > 15) because the data argument was 
# piped in. The functions mentioned above all accept the data that’s being
# passed into them because they’re part of the tidyverse. (Note that this 
# is not true for all functions, but we can talk about that later.)
# 
# Here’s another simple example using a datafram that we built ourselves:
#   
my_df <- data.frame(
    species = c("Pichu", "Pikachu", "Raichu"),
    number = c(172, 25, 26),
    location = c("Johto", "Kanto", "Kanto")
  )

my_df %>%  # take the dataframe object...
  dplyr::select(species, number) %>%   # ...then select these columns...
  dplyr::filter(number %in% c(172, 26))  # ...then filter on these values
# 
# CHALLENGE!
# Write a pipe recipe that creates a new dataframe called my_poke that 
# takes the pokemon dataframe and:
#   
# select()s only the species and combat_power columns
# left_join()s the pokedex dataframe by species
# filter()s by those with a type1 that’s ‘normal’


# Summaries ---------------------------------------------------------------
# Assuming we’ve now wrangled out data using the dplyr functions, we can do
# some quick, readable summarisation that’s way better than the summary() 
# function.

# So let’s use our knowledge – and some new functions – to get the top 5 
# pokemon by count.

pokemon %>%  # take the dataframe
  dplyr::group_by(species) %>%   # group it by species
  dplyr::tally() %>%   # tally up (count) the number of instances (the results of the previous pipe go in the brackets by default)
  dplyr::arrange(desc(n)) %>%  # arrange in descending order
  dplyr::slice(1:5)  # and slice out the first five rows

# The order of your functions is important – remember it’s like a recipe. 
# Don’t crack the eggs on your cake just before serving. Do it near the 
# beginning somewhere, I guess (I [Dr Dray] am not much of a cake maker).
# 
# There’s also a specific summarise() function that lets you, well… summarise.
# (also works with US spelling; summarize())

pokemon_join %>%  # take the dataframe (join from pokemon and pokedex)
  dplyr::group_by(type1) %>%   # group by variable
  dplyr::summarise( # summarise it by...
    count = n(),  # counting the number
    mean_cp = round(mean(combat_power), 0)  # and take a mean to nearest whole number
  ) %>% 
  dplyr::arrange(desc(mean_cp))  # then organise in descending order of this column

# 
# Note that you can group by more than one thing as well. We can group on 
# the weight_bin category within the type1 category, for example.

pokemon_join %>%
  dplyr::group_by(type1, weight_bin) %>% 
  dplyr::summarise(
    mean_weight = mean(weight_kg),
    count = n()
  )

# Plot the data
# We’re going to keep this very short and dangle it like a rare candy 
# in front of your nose. We’ll revisit this in more depth in a later 
# session. For now, we’re going to use a package called ggplot2 to 
# create some simple charts.

# CHALLENGE!
# The ‘gg’ in ‘ggplot2’ stands for ‘grammar of graphics’. This is a
# way of thinking about plotting as having a ‘grammar’ – ‘elements 
# that can be applied in succession to create a plot. This is ’the 
# idea that you can build every graph from the same few components’: 
# a data set, geoms (marks representing data points), a co-ordinate 
# system and some other things.
# 
# The ggplot() function from the ggplot2 package is how you create 
# these plots. You build up the graphical elements using the + rather 
# than a pipe. Think about it as placing down a canvas and then adding
# layers on top.

pokemon %>%
  ggplot2::ggplot() +
  ggplot2::geom_boxplot(aes(x = weight_bin, y = combat_power))

# ggplot plays nicely with the pipe – it’s part of the tidyverse – 
# so we can create recipes that combine data reading, data manipulation
# and plotting all in one go. Let’s do some manipulation before 
# plotting and then introduce some new elements to our plot that 
# simplify the theme and change the labels.

pokemon_join %>%
  dplyr::filter(type1 %in% c("fire", "water", "grass")) %>% 
  ggplot2::ggplot() +
  ggplot2::geom_violin(aes(x = type1, y = combat_power)) +
  ggplot2::theme_bw() +
  ggplot2::labs(
    title = "CP by type",
    x = "Primary type",
    y = "Combat power"
  )

#How about a dotplot? Coloured by type1?
  
pokemon_join %>%
  dplyr::filter(type1 %in% c("fire", "water", "grass")) %>%
  ggplot2::ggplot() +
  ggplot2::geom_point(aes(x = pokedex_number, y = height_m, colour = type1))
# 
# CHALLENGE!
# Create a boxplot for Pokemon with type1 of ‘normal’, ‘poison’, 
# ‘ground’ and ‘water’ against their hit-points


#fin