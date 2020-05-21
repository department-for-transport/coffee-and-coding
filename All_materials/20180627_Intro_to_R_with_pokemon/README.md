Intro\_to\_R\_with\_pokemon.R
=============================

#### *Tamsin Forbes*


    #this script has been taken from section 5-8 of the online tutorial 

Beginner R and RStudio training’ by Matt Dray (DfE)

    #at the following web address
    #https://matt-dray.github.io/beginner-r-feat-pkmn/#5_get_data_in_and_look_at_it
      
    #install required packages if not already installed
    #install.packages('tidyverse') #note quotes

    #load required packages, note no quotes
    library(tidyverse)

    ## ── Attaching packages ─────────────────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.0.0     ✔ purrr   0.2.5
    ## ✔ tibble  1.4.2     ✔ dplyr   0.7.6
    ## ✔ tidyr   0.8.1     ✔ stringr 1.3.1
    ## ✔ readr   1.1.1     ✔ forcats 0.3.0

    ## ── Conflicts ────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

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

    ## Parsed with column specification:
    ## cols(
    ##   species = col_character(),
    ##   combat_power = col_integer(),
    ##   hit_points = col_integer(),
    ##   weight_kg = col_double(),
    ##   weight_bin = col_character(),
    ##   height_m = col_double(),
    ##   height_bin = col_character(),
    ##   fast_attack = col_character(),
    ##   charge_attack = col_character()
    ## )

    #data inspection
    tibble::glimpse(pokemon)

    ## Observations: 696
    ## Variables: 9
    ## $ species       <chr> "krabby", "geodude", "venonat", "parasect", "eev...
    ## $ combat_power  <int> 51, 85, 129, 171, 172, 131, 96, 11, 112, 156, 12...
    ## $ hit_points    <int> 15, 23, 38, 32, 37, 320, 21, 10, 30, 35, 26, 38,...
    ## $ weight_kg     <dbl> 5.82, 20.88, 20.40, 19.20, 4.18, 11.20, 3.49, 36...
    ## $ weight_bin    <chr> "normal", "normal", "extra_small", "extra_small"...
    ## $ height_m      <dbl> 0.36, 0.37, 0.92, 0.87, 0.25, 0.48, 0.27, 0.80, ...
    ## $ height_bin    <chr> "normal", "normal", "normal", "normal", "normal"...
    ## $ fast_attack   <chr> "mud_shot", "rock_throw", "confusion", "bug_bite...
    ## $ charge_attack <chr> "vice_grip", "rock_tomb", "poison_fang", "x-scis...

    #print to console
    base::print(pokemon)

    ## # A tibble: 696 x 9
    ##    species combat_power hit_points weight_kg weight_bin height_m height_bin
    ##    <chr>          <int>      <int>     <dbl> <chr>         <dbl> <chr>     
    ##  1 krabby            51         15      5.82 normal        0.36  normal    
    ##  2 geodude           85         23     20.9  normal        0.37  normal    
    ##  3 venonat          129         38     20.4  extra_sma…    0.92  normal    
    ##  4 parase…          171         32     19.2  extra_sma…    0.87  normal    
    ##  5 eevee            172         37      4.18 extra_sma…    0.25  normal    
    ##  6 voltorb          131        320     11.2  normal        0.48  normal    
    ##  7 shelld…           96         21      3.49 normal        0.27  normal    
    ##  8 staryu            11         10     36.4  normal        0.8   normal    
    ##  9 nidora…          112         30      9.49 normal        0.51  normal    
    ## 10 poliwag          156         35     11.2  normal        0.580 normal    
    ## # ... with 686 more rows, and 2 more variables: fast_attack <chr>,
    ## #   charge_attack <chr>

    #view data
    View(pokemon) # opens tab with data, note the capital 'V'
    utils::View(pokemon) # opens a popup with data, navigate with arrow keys

    #summary {base} stats
    base::summary(pokemon)

    ##    species           combat_power      hit_points       weight_kg      
    ##  Length:696         Min.   :  10.0   Min.   : 10.00   Min.   :  0.050  
    ##  Class :character   1st Qu.:  76.0   1st Qu.: 23.00   1st Qu.:  2.795  
    ##  Mode  :character   Median : 160.0   Median : 33.00   Median :  6.440  
    ##                     Mean   : 206.1   Mean   : 37.42   Mean   : 15.053  
    ##                     3rd Qu.: 286.0   3rd Qu.: 47.00   3rd Qu.: 20.163  
    ##                     Max.   :1636.0   Max.   :320.00   Max.   :492.040  
    ##   weight_bin           height_m       height_bin        fast_attack       
    ##  Length:696         Min.   :0.2000   Length:696         Length:696        
    ##  Class :character   1st Qu.:0.3100   Class :character   Class :character  
    ##  Mode  :character   Median :0.5050   Mode  :character   Mode  :character  
    ##                     Mean   :0.6544                                        
    ##                     3rd Qu.:0.8900                                        
    ##                     Max.   :9.5200                                        
    ##  charge_attack     
    ##  Length:696        
    ##  Class :character  
    ##  Mode  :character  
    ##                    
    ##                    
    ## 

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

    ## # A tibble: 696 x 2
    ##    hit_points species     
    ##         <int> <chr>       
    ##  1         15 krabby      
    ##  2         23 geodude     
    ##  3         38 venonat     
    ##  4         32 parasect    
    ##  5         37 eevee       
    ##  6        320 voltorb     
    ##  7         21 shellder    
    ##  8         10 staryu      
    ##  9         30 nidoran_male
    ## 10         35 poliwag     
    ## # ... with 686 more rows

    #select by dropping columns
    dplyr::select(
      pokemon,  # data frame first
      -hit_points, -combat_power, -fast_attack, -weight_bin  # columns to drop
    )

    ## # A tibble: 696 x 5
    ##    species      weight_kg height_m height_bin charge_attack
    ##    <chr>            <dbl>    <dbl> <chr>      <chr>        
    ##  1 krabby            5.82    0.36  normal     vice_grip    
    ##  2 geodude          20.9     0.37  normal     rock_tomb    
    ##  3 venonat          20.4     0.92  normal     poison_fang  
    ##  4 parasect         19.2     0.87  normal     x-scissor    
    ##  5 eevee             4.18    0.25  normal     body_slam    
    ##  6 voltorb          11.2     0.48  normal     discharge    
    ##  7 shellder          3.49    0.27  normal     bubble_beam  
    ##  8 staryu           36.4     0.8   normal     bubble_beam  
    ##  9 nidoran_male      9.49    0.51  normal     body_slam    
    ## 10 poliwag          11.2     0.580 normal     body_slam    
    ## # ... with 686 more rows

    #select columns with similar names
    dplyr::select(pokemon, starts_with("weight"))

    ## # A tibble: 696 x 2
    ##    weight_kg weight_bin 
    ##        <dbl> <chr>      
    ##  1      5.82 normal     
    ##  2     20.9  normal     
    ##  3     20.4  extra_small
    ##  4     19.2  extra_small
    ##  5      4.18 extra_small
    ##  6     11.2  normal     
    ##  7      3.49 normal     
    ##  8     36.4  normal     
    ##  9      9.49 normal     
    ## 10     11.2  normal     
    ## # ... with 686 more rows

    dplyr::select(pokemon, contains("bin"))

    ## # A tibble: 696 x 2
    ##    weight_bin  height_bin
    ##    <chr>       <chr>     
    ##  1 normal      normal    
    ##  2 normal      normal    
    ##  3 extra_small normal    
    ##  4 extra_small normal    
    ##  5 extra_small normal    
    ##  6 normal      normal    
    ##  7 normal      normal    
    ##  8 normal      normal    
    ##  9 normal      normal    
    ## 10 normal      normal    
    ## # ... with 686 more rows

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

    ## # A tibble: 11 x 9
    ##    species combat_power hit_points weight_kg weight_bin height_m height_bin
    ##    <chr>          <int>      <int>     <dbl> <chr>         <dbl> <chr>     
    ##  1 jiggly…          221         93      7.04 extra_lar…    0.56  normal    
    ##  2 jiggly…          156         80      6.83 normal        0.55  normal    
    ##  3 jiggly…          349        119      3.57 extra_sma…    0.42  normal    
    ##  4 jiggly…           10         22      4.92 normal        0.44  normal    
    ##  5 jiggly…          188         94      6.56 normal        0.52  normal    
    ##  6 jiggly…           33         39      7.14 extra_lar…    0.580 normal    
    ##  7 jiggly…           56         51      5.55 normal        0.49  normal    
    ##  8 jiggly…           66         51      8.13 extra_lar…    0.6   normal    
    ##  9 jiggly…          289        111      5.02 normal        0.44  normal    
    ## 10 jiggly…          348        119      4.91 normal        0.47  normal    
    ## 11 jiggly…          486        146      4.9  normal        0.44  normal    
    ## # ... with 2 more variables: fast_attack <chr>, charge_attack <chr>

    #now everything except for one species
    dplyr::filter(pokemon, species != "pidgey")  # not equal to

    ## # A tibble: 610 x 9
    ##    species combat_power hit_points weight_kg weight_bin height_m height_bin
    ##    <chr>          <int>      <int>     <dbl> <chr>         <dbl> <chr>     
    ##  1 krabby            51         15      5.82 normal        0.36  normal    
    ##  2 geodude           85         23     20.9  normal        0.37  normal    
    ##  3 venonat          129         38     20.4  extra_sma…    0.92  normal    
    ##  4 parase…          171         32     19.2  extra_sma…    0.87  normal    
    ##  5 eevee            172         37      4.18 extra_sma…    0.25  normal    
    ##  6 voltorb          131        320     11.2  normal        0.48  normal    
    ##  7 shelld…           96         21      3.49 normal        0.27  normal    
    ##  8 staryu            11         10     36.4  normal        0.8   normal    
    ##  9 nidora…          112         30      9.49 normal        0.51  normal    
    ## 10 poliwag          156         35     11.2  normal        0.580 normal    
    ## # ... with 600 more rows, and 2 more variables: fast_attack <chr>,
    ## #   charge_attack <chr>

    #filter on three species
    dplyr::filter(
      pokemon,
      species %in% c("staryu", "psyduck", "charmander")
    )

    ## # A tibble: 39 x 9
    ##    species combat_power hit_points weight_kg weight_bin height_m height_bin
    ##    <chr>          <int>      <int>     <dbl> <chr>         <dbl> <chr>     
    ##  1 staryu            11         10      36.4 normal         0.8  normal    
    ##  2 psyduck           97         26      26.0 extra_lar…     0.9  normal    
    ##  3 psyduck           41         17      23.6 normal         0.91 normal    
    ##  4 staryu           225         25      36.4 normal         0.73 normal    
    ##  5 staryu           154         23      18.8 extra_sma…     0.59 extra_sma…
    ##  6 staryu            11         10      18.9 extra_sma…     0.68 normal    
    ##  7 staryu           260         29      44.2 extra_lar…     0.85 normal    
    ##  8 psyduck           44         19      23.4 normal         0.72 normal    
    ##  9 staryu           112         19      28.1 normal         0.78 normal    
    ## 10 staryu           144         23      50.4 extra_lar…     0.97 normal    
    ## # ... with 29 more rows, and 2 more variables: fast_attack <chr>,
    ## #   charge_attack <chr>

    #we can work with numbers too
    dplyr::filter(
      pokemon
      , combat_power > 900 & combat_power < 1000 # two conditions
      , hit_points < 100  
    ) # note the '&'

    ## # A tibble: 6 x 9
    ##   species combat_power hit_points weight_kg weight_bin height_m height_bin
    ##   <chr>          <int>      <int>     <dbl> <chr>         <dbl> <chr>     
    ## 1 gyarad…          955         94     177.  normal         5.58 normal    
    ## 2 magmar           936         70      40.4 normal         1.16 normal    
    ## 3 magmar           991         73      31.1 extra_sma…     1.23 normal    
    ## 4 magmar           963         75      42.5 normal         1.28 normal    
    ## 5 fearow           954         83      40.6 normal         1.2  normal    
    ## 6 electa…          962         74      39.0 extra_lar…     1.26 normal    
    ## # ... with 2 more variables: fast_attack <chr>, charge_attack <chr>

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

    ## # A tibble: 696 x 6
    ##    species      combat_power hit_points power_index caught area 
    ##    <chr>               <int>      <int>       <int>  <dbl> <chr>
    ##  1 krabby                 51         15         765      1 kanto
    ##  2 geodude                85         23        1955      1 kanto
    ##  3 venonat               129         38        4902      1 kanto
    ##  4 parasect              171         32        5472      1 kanto
    ##  5 eevee                 172         37        6364      1 kanto
    ##  6 voltorb               131        320       41920      1 kanto
    ##  7 shellder               96         21        2016      1 kanto
    ##  8 staryu                 11         10         110      1 kanto
    ##  9 nidoran_male          112         30        3360      1 kanto
    ## 10 poliwag               156         35        5460      1 kanto
    ## # ... with 686 more rows

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

    ## # A tibble: 696 x 3
    ##    hit_points species      common
    ##         <int> <chr>        <chr> 
    ##  1         15 krabby       no    
    ##  2         23 geodude      no    
    ##  3         38 venonat      no    
    ##  4         32 parasect     no    
    ##  5         37 eevee        yes   
    ##  6        320 voltorb      no    
    ##  7         21 shellder     no    
    ##  8         10 staryu       yes   
    ##  9         30 nidoran_male no    
    ## 10         35 poliwag      no    
    ## # ... with 686 more rows

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

    ## # A tibble: 696 x 9
    ##    species combat_power hit_points weight_kg weight_bin height_m height_bin
    ##    <chr>          <int>      <int>     <dbl> <chr>         <dbl> <chr>     
    ##  1 diglett           79         10      0.79 normal         0.2  normal    
    ##  2 pidgey           254         44      0.82 extra_sma…     0.21 extra_sma…
    ##  3 rattata           23         11      1.52 extra_sma…     0.22 extra_sma…
    ##  4 pidgey           229         43      0.85 extra_sma…     0.22 extra_sma…
    ##  5 weedle            17         13      2.25 extra_sma…     0.22 extra_sma…
    ##  6 spearow          296         47      0.69 extra_sma…     0.22 extra_sma…
    ##  7 spearow           89         26      1.06 extra_sma…     0.22 extra_sma…
    ##  8 pidgey           256         46      0.82 extra_sma…     0.23 normal    
    ##  9 rattata           64         17      2.7  normal         0.23 normal    
    ## 10 diglett           64         10      1.05 extra_lar…     0.23 normal    
    ## # ... with 686 more rows, and 2 more variables: fast_attack <chr>,
    ## #   charge_attack <chr>

    #And in reverse order (tallest first):
    dplyr::arrange(pokemon, desc(height_m))  # descending

    ## # A tibble: 696 x 9
    ##    species combat_power hit_points weight_kg weight_bin height_m height_bin
    ##    <chr>          <int>      <int>     <dbl> <chr>         <dbl> <chr>     
    ##  1 onix             299         38    192.   normal         9.52 normal    
    ##  2 gyarad…          955         94    177.   normal         5.58 normal    
    ##  3 pidgey            76         26      1.25 extra_sma…     2.5  normal    
    ##  4 ekans            206         35     11.6  extra_lar…     2.46 normal    
    ##  5 lapras          1636        161    163.   extra_sma…     2.22 normal    
    ##  6 snorlax          300         85    492.   normal         2.11 normal    
    ##  7 dratini          298         42      4.4  extra_lar…     2.08 normal    
    ##  8 dratini          332         44      4.75 extra_lar…     1.99 normal    
    ##  9 ekans             95         24      5.2  normal         1.93 normal    
    ## 10 dratini          316         40      3.13 normal         1.91 normal    
    ## # ... with 686 more rows, and 2 more variables: fast_attack <chr>,
    ## #   charge_attack <chr>

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

    ## Parsed with column specification:
    ## cols(
    ##   species = col_character(),
    ##   pokedex_number = col_integer(),
    ##   type1 = col_character(),
    ##   type2 = col_character()
    ## )

    tibble::glimpse(pokedex)  # let's inspect its contents

    ## Observations: 801
    ## Variables: 4
    ## $ species        <chr> "bulbasaur", "ivysaur", "venusaur", "charmander...
    ## $ pokedex_number <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, ...
    ## $ type1          <chr> "grass", "grass", "grass", "fire", "fire", "fir...
    ## $ type2          <chr> "poison", "poison", "poison", NA, NA, "flying",...

    # Now we’re going to join this new data to our pokemon data. The key 
    # or matching these in the species column, which exists in both datasets.

    pokemon_join <- dplyr::left_join(
      x = pokemon,  # to this table...
      y = pokedex,   # ...join this table
      by = "species"  # on this key
    )

    tibble::glimpse(pokemon_join)

    ## Observations: 696
    ## Variables: 12
    ## $ species        <chr> "krabby", "geodude", "venonat", "parasect", "ee...
    ## $ combat_power   <int> 51, 85, 129, 171, 172, 131, 96, 11, 112, 156, 1...
    ## $ hit_points     <int> 15, 23, 38, 32, 37, 320, 21, 10, 30, 35, 26, 38...
    ## $ weight_kg      <dbl> 5.82, 20.88, 20.40, 19.20, 4.18, 11.20, 3.49, 3...
    ## $ weight_bin     <chr> "normal", "normal", "extra_small", "extra_small...
    ## $ height_m       <dbl> 0.36, 0.37, 0.92, 0.87, 0.25, 0.48, 0.27, 0.80,...
    ## $ height_bin     <chr> "normal", "normal", "normal", "normal", "normal...
    ## $ fast_attack    <chr> "mud_shot", "rock_throw", "confusion", "bug_bit...
    ## $ charge_attack  <chr> "vice_grip", "rock_tomb", "poison_fang", "x-sci...
    ## $ pokedex_number <int> 98, 74, 48, 47, 133, 100, 90, 120, 32, 60, 46, ...
    ## $ type1          <chr> "water", "rock", "bug", "bug", "normal", "elect...
    ## $ type2          <chr> NA, "ground", "poison", "grass", NA, NA, NA, NA...

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

    ## Parsed with column specification:
    ## cols(
    ##   species = col_character(),
    ##   combat_power = col_integer(),
    ##   hit_points = col_integer(),
    ##   weight_kg = col_double(),
    ##   weight_bin = col_character(),
    ##   height_m = col_double(),
    ##   height_bin = col_character(),
    ##   fast_attack = col_character(),
    ##   charge_attack = col_character()
    ## )

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

    ## Parsed with column specification:
    ## cols(
    ##   species = col_character(),
    ##   combat_power = col_integer(),
    ##   hit_points = col_integer(),
    ##   weight_kg = col_double(),
    ##   weight_bin = col_character(),
    ##   height_m = col_double(),
    ##   height_bin = col_character(),
    ##   fast_attack = col_character(),
    ##   charge_attack = col_character()
    ## )

    tibble::glimpse(pokemon_piped)

    ## Observations: 204
    ## Variables: 8
    ## $ species       <chr> "geodude", "venonat", "parasect", "staryu", "ven...
    ## $ combat_power  <int> 85, 129, 171, 11, 137, 256, 234, 157, 140, 246, ...
    ## $ hit_points    <int> 23, 38, 32, 10, 38, 64, 33, 49, 56, 42, 45, 34, ...
    ## $ weight_kg     <dbl> 20.88, 20.40, 19.20, 36.41, 41.23, 30.20, 73.81,...
    ## $ height_m      <dbl> 0.37, 0.92, 0.87, 0.80, 1.26, 0.84, 1.52, 0.94, ...
    ## $ fast_attack   <chr> "rock_throw", "confusion", "bug_bite", "water_gu...
    ## $ charge_attack <chr> "rock_tomb", "poison_fang", "x-scissor", "bubble...
    ## $ organism      <chr> "pokemon", "pokemon", "pokemon", "pokemon", "pok...

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

    ##   species number
    ## 1   Pichu    172
    ## 2  Raichu     26

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

    ## # A tibble: 5 x 2
    ##   species     n
    ##   <chr>   <int>
    ## 1 pidgey     86
    ## 2 rattata    78
    ## 3 drowzee    64
    ## 4 spearow    42
    ## 5 zubat      35

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

    ## # A tibble: 16 x 3
    ##    type1    count mean_cp
    ##    <chr>    <int>   <dbl>
    ##  1 fire        16     510
    ##  2 fairy        5     412
    ##  3 <NA>         3     390
    ##  4 electric    12     373
    ##  5 fighting     1     358
    ##  6 grass       17     357
    ##  7 dragon       4     326
    ##  8 psychic     70     301
    ##  9 ice          7     275
    ## 10 ground       7     214
    ## 11 water      157     192
    ## 12 rock         9     190
    ## 13 bug         63     185
    ## 14 ghost       12     170
    ## 15 poison      59     168
    ## 16 normal     254     157

    # 
    # Note that you can group by more than one thing as well. We can group on 
    # the weight_bin category within the type1 category, for example.

    pokemon_join %>%
      dplyr::group_by(type1, weight_bin) %>% 
      dplyr::summarise(
        mean_weight = mean(weight_kg),
        count = n()
      )

    ## # A tibble: 40 x 4
    ## # Groups:   type1 [?]
    ##    type1    weight_bin  mean_weight count
    ##    <chr>    <chr>             <dbl> <int>
    ##  1 bug      extra_large       29.1      9
    ##  2 bug      extra_small        8.98    16
    ##  3 bug      normal            10.6     38
    ##  4 dragon   extra_large        4.58     2
    ##  5 dragon   normal             2.95     2
    ##  6 electric extra_large       18.7      3
    ##  7 electric extra_small        5.74     2
    ##  8 electric normal            18.5      7
    ##  9 fairy    extra_large        9.47     2
    ## 10 fairy    normal             7.96     3
    ## # ... with 30 more rows

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

<img src="images/b9884d31e4ea870f9534d8de2f09ad999550bb46.png" width="672" />

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

<img src="images/765e304eef8faac1113c65b58591a7f543f08c7c.png" width="672" />

    #How about a dotplot? Coloured by type1?
      
    pokemon_join %>%
      dplyr::filter(type1 %in% c("fire", "water", "grass")) %>%
      ggplot2::ggplot() +
      ggplot2::geom_point(aes(x = pokedex_number, y = height_m, colour = type1))

<img src="images/f8989818ccd5268d96e76370eca24656b0f87ff5.png" width="672" />

    # 
    # CHALLENGE!
    # Create a boxplot for Pokemon with type1 of ‘normal’, ‘poison’, 
    # ‘ground’ and ‘water’ against their hit-points


    #fin
