---
title: "what is my {purrr}pose?"
author: "Tamsin Forbes"
date: "06/07/2020"
output: 
  html_document:
    theme: spacelab
    toc: yes
    toc_depth: 4
    toc_float: yes
    keep_md: yes
---

## to iterate...

<div style="float:right;position: relative; top: -80px;">
<img src="image/purrr_butter_robot.png" width="400px" />

</div>


The {purrr} package is one of the {tidyverse} staples. It faciliates and optimises iteration and plays nicely with other {tidyverse} functions. The advantage over for loops is that {purrr} makes it easier for the user to write their own functions in a "complete and consistent manner" (for more on this see r-bloggers [to purrr or not to purrr](https://www.r-bloggers.com/to-purrr-or-not-to-purrr/)).

This talk aims to provide functional programming examples of some of the common functions from the {purrr} package. These have basic descriptions in the excellent [{purrr} cheatsheet](https://github.com/rstudio/cheatsheets/blob/master/purrr.pdf). I have also included some examples on how to use purrr to import multiple excel workbooks/worksheets/individual cells from the work I did for our [DfT R Cookbook chapter 3.6](https://departmentfortransport.github.io/R-cookbook/data-import.html#xlsx-and-.xls).

<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />

## Import packages

For full list of tidyverse packages see [website](https://www.tidyverse.org/packages/).

```r
library(tidyverse) #suite of packages including dplyr, stringr, purrr, readr etc 
library(fs) #file system operations package, reading filenames in folders etc
library(knitr) #general purpose tool for dynamic report generation in R 
library(kableExtra) #presentation of complex tables with customizable styles
library(DT) #presentation of tables (wrapper of JavaScript library DataTables)
```

## Create some data

A variety of vectors, lists and dataframes for use in this code. Not all are used below.

```r
#some vectors, vectors must be all the same data type
#character vectors
animals <- c("ant", "bat", "cat", "dog", "elk", "fox", "gnu")
words <- c("she", "sells", "seashells")
villages <- c("Godric's Hollow", "Ottery St. Catchpole")
saturn_moons <- c("Titan", "Mimas", "Europa", "Phoebe", "Tethys", "Rhea")

#numeric vectors
integers <- c(4, 6, 2, 7, 4, 6, 3, 6)
doubles <- c(5.3, 4.6, 2.5, 7.45, 9.23)

#logical
logical <- c(T, F, F, F, T, T, F, T, T)

#lists, lists can hold a mixture of data types, and be nested
simple_list <- list("just", "some", "words")
alist <- list(animals, integers, logical)
nested_list <- list(saturn_moons, list(words, logical), villages)
list_moons <- list("Titan", "Mimas", "Europa", "Phoebe", "Tethys", "Rhea" )

set.seed(12345) #set seed to make random seelctions repeatable
#dataframes are lists with special propoerties
#a column must contain only one data type, and each column must have the same length
df1 <- tibble::tibble(
  "animal" = sample(animals, 20, replace = TRUE)
  , "height" = runif(n = 20, min = 1, max = 20)
)

#a column can contain a vector of lists, including nested lists
df2 <- tibble::tibble(
  "word" = words
  , "lists" = list(logical, saturn_moons, list(integers, villages))
)

#a dataframe of fruit consumption in kilos per month
monthly_fruit_consumption <- tibble::tibble(
  fruit = c("banana", "gooseberry", "peach", 'raspberry', 'guava')
  , month = c('Mar', 'May', 'Apr', 'Mar', 'May')
  , mass_kilos = c(12, 13, 15, 11, 9)
)
```


## Input: list or vector
The {purrr} functions can receive a list or vector of elements, and you should note that these have different outputs. For example


```r
list(1,2,3)
```

```
## [[1]]
## [1] 1
## 
## [[2]]
## [1] 2
## 
## [[3]]
## [1] 3
```


```r
c(1,2,3)
```

```
## [1] 1 2 3
```

## Accessing elements

### Accessing a list: beware of nestedness; [] vs [[]]

#### A list

```r
simple_list
```

```
## [[1]]
## [1] "just"
## 
## [[2]]
## [1] "some"
## 
## [[3]]
## [1] "words"
```

#### Individual elements of the list

```r
simple_list[[1]]
```

```
## [1] "just"
```

```r
simple_list[[3]]
```

```
## [1] "words"
```

#### Lists within the list

```r
simple_list[2]
```

```
## [[1]]
## [1] "some"
```

#### The difference when using the output

```r
glue::glue("the first element is: ", simple_list[1])
```

```
## the first element is: list("just")
```

```r
glue::glue("the first element is: ", simple_list[[1]])
```

```
## the first element is: just
```

### Accessing a vector: 

#### A vector

```r
words
```

```
## [1] "she"       "sells"     "seashells"
```

#### Individual vector elements

```r
#both ok but [[]] not necessary
words[1]
```

```
## [1] "she"
```

```r
words[[1]] #not necessary
```

```
## [1] "she"
```

#### More than one element

```r
words[2:3] #ok
```

```
## [1] "sells"     "seashells"
```

```r
#words[[2:3]] #not ok
```

### Accessing a dataframe column vector

```r
df1$animal[4]
```

```
## [1] "gnu"
```

```r
df1$animal[1:4]
```

```
## [1] "fox" "gnu" "fox" "gnu"
```

###  Accessing a dataframe column list
#### The first list returned as a logical vector

```r
df2$lists[[1]]
```

```
## [1]  TRUE FALSE FALSE FALSE  TRUE  TRUE FALSE  TRUE  TRUE
```

```r
str(df2$lists[[1]])
```

```
##  logi [1:9] TRUE FALSE FALSE FALSE TRUE TRUE ...
```

#### The first list returned as a list containing a logical vector...

```r
df2$lists[1]
```

```
## [[1]]
## [1]  TRUE FALSE FALSE FALSE  TRUE  TRUE FALSE  TRUE  TRUE
```

```r
str(df2$lists[1])
```

```
## List of 1
##  $ : logi [1:9] TRUE FALSE FALSE FALSE TRUE TRUE ...
```

#### The fourth element from the first list in the column

```r
df2$lists[[1]][4]
```

```
## [1] FALSE
```

So mind your lists and vectors!


## `map` overview

The workhorse of {purrr} is `map` and related functions. Each of the `map` functions takes a list/vector and applies a function to each element. Each version of `map` has a specific output type: 

* `map` -> list
* `map_chr` -> character vector
* `map_int` -> integer vector
* `map_lgl` -> logical vector
* `map_dfr` -> row binds outputs into a dataframe
* `map_dfc` -> column binds outputs into a dataframe

The `map2_` versions of the above (`map2`, `map2_chr`, `map2_int` etc) each take two list/vector inputs, **which must be the same length**, then apply the function to each **pair**. 

## Argument syntax

There are a few different ways to give {purrr} functions their arguments. The list/vector argument is `.x`, and `.y` for feeding two simultaneously. The function argument is `.f` and other arguments are similarly prefixed by `.`.

#### Single argument
For a simple use case of a purrr function you can just pass the list/vector and the function name, *without any arguments or brackets*, and it will implicitly feed the list/vector elements into the first argument of the specified function. 

Input a character vector of individual words and return the length of each

```r
purrr::map(.x = words, .f = stringr::str_length)
```

```
## [[1]]
## [1] 3
## 
## [[2]]
## [1] 5
## 
## [[3]]
## [1] 9
```

#### Multiple arguments

If the function you want to apply takes more than one argument, or the first argument is not the list, or you want to apply something more complicated then you need to use `~` and specify where `.x` goes:


```r
purrr::map(.x = words
           , .f = ~ glue::glue("'", .x, "'", " has ", stringr::str_length(.x), " letters."))
```

```
## [[1]]
## 'she' has 3 letters.
## 
## [[2]]
## 'sells' has 5 letters.
## 
## [[3]]
## 'seashells' has 9 letters.
```

## Function 1: `map_int`, `map_if`, `map_chr`

Say you wanted to send a secret message, where each word is encoded based on the number of letters it has. The function, `encode_word` below takes a list/vector of words, extracts each word, applies a shift to each letter (dependent on word length) puts the new word back together and outputs the vector of encoded words. In the process we use `map_int`, `map_if` and `map_chr`.

### `map_int`

This will be used inside the function to collect an integer vector of the index number of each letter of the word from the built in `letters` character vector of the lowercase alphabet, in which `letters[1]` = a, `letters[26]` = z etc. 

```r
purrr::map_int(.x = c("h", "e", "l", "l", "o"), ~ stringr::str_which(letters, .x))
```

```
## [1]  8  5 12 12 15
```

### `map_if`

The fact that R indexes from 1 instead of 0 causes a little problem here which we use `map_if` to circumvent. We want to shift each letter by the word length, for example each letter of "way" will be shifted forward 3 to "zdb". When we add on the word length to each letter we want it to wrap around, so we use addtion modulo 26. However, 26 %% 26 = 0, and `letters[0]` does not exist, but is equivalent to `letters[26]` which is "z". So we use `map_if` to deal with this exception. `map_if` takes a predicate function, `.p` which allows you to specify a condition that elements of `.x` must pass for the function in `.f` to be applied. Elements that fail `.p` can be dealt with by an alternative function in `.else`, or you can leave this blank to just ignore them.

```r
word_length = stringr::str_length("way")
purrr::map_if(.x = c(23, 1, 25) #letters indices of "w", "a", "y""
              , .p = ~ (.x + word_length) %% 26 != 0 #conditon: not a multiple of 26
              , .f = ~ letters[(.x + word_length) %% 26] #apply to elements that pass
              , .else = ~ letters[26]) #apply to elements that fail
```

```
## [[1]]
## [1] "z"
## 
## [[2]]
## [1] "d"
## 
## [[3]]
## [1] "b"
```
### encode_word function
Function to encode a word based on its length

```r
encode_word <- function(word){
  #check word is only alphabet characters, remove punctuation, numbers
  #
  word <- stringr::str_to_lower(word) #make lower case
  word_length <- stringr::str_length(word) #get length of word
  word_letters <- unlist( stringr::str_split(word, "") ) #get vector of letters
  #get integer vector of the index in letters of each letter
  letters_index <- purrr::map_int(.x = word_letters, ~ stringr::str_which(letters, .x))
  #apply shift based on word length using map_if to take care of instance where 
  #the sum modulo 26 = 0. letters[0] does not exist, but should be letters[26]
  shifted_letters <-  purrr::map_if(.x = letters_index
                                    , .p = ~ (.x + word_length) %% 26 != 0
                                    , .f = ~ letters[(.x + word_length) %% 26]
                                    , .else = ~ letters[26])
  #map_if returns a list so collapse this list of encoded letters to word
  encoded_word <- stringr::str_c(shifted_letters, sep = "", collapse = "")
    
  return(encoded_word)
}
```

### `map_chr`
Now we have a function that can encode a single word we can use `map_chr` to neatly apply it to a character vector of words, and return a character vector. Here I've encoded some end of alphabet letters to check it's working properly - I suppose this could/should make up some unit test...

```r
purrr::map_chr(.x = c("y", "xy", "wxy"), ~ encode_word(word = .x))
```

```
## [1] "z"   "za"  "zab"
```

And here's some actual words being encoded:

```r
saturn_moons
```

```
## [1] "Titan"  "Mimas"  "Europa" "Phoebe" "Tethys" "Rhea"
```

```r
purrr::map_chr(.x = saturn_moons, ~ encode_word(word = .x))
```

```
## [1] "ynyfs"  "rnrfx"  "kaxuvg" "vnukhk" "zkzney" "vlie"
```


If I developed this to encode a message I would do something like extract the whole message into a string, remove punctuation and numbers, split it on the spaces to get the character vector of words. But I guess I would want to put each encoded word back, so would have to work out a way to preserve its original position in the message. Anyway I have no need of this function just now so I won't bother...

## Function 2: `map_dfr`

Now I'm going to shamelessly steal from my own work and include a few examples of user defined functions (UDFs) involving {purrr} to import data from MS Excel one/many cells/worksheets/workbooks in. 

### `map_dfr`
You have a workbook of data split across many sheets. The data in each sheet is consistent, same variable names and number, like so:
![](image/pokemon_collection_point.png)
You want to read in each sheet and row bind into a dataframe. Enter `map_dfr`. The following UDF `read_and_combine_sheets` takes the path to the workbook as its only input and returns a row bound dataframe of the data from each sheet, also adding a sheet id column comprised of the sheet name so you can see where it came from.

```r
read_and_combine_sheets <- function(path){
  readxl::excel_sheets(path = path) %>% 
  purrr::set_names() %>% #collect the names of the sheets in a list
   purrr::map_dfr( #list of sheet names is piped implicitly into .x
     .f = ~ readxl::read_excel(path = path, sheet = .x)
     , .id = "sheet" #supply name of id column;  value is taken from .x
   )
}
```

Let's try it out on the pokemon January 2019 collections data pictured above.

```r
DT::datatable(data = read_and_combine_sheets(path = "data/pokemon_201901.xlsx"))
```

<!--html_preserve--><div id="htmlwidget-c86dedc542520f0b0ea0" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-c86dedc542520f0b0ea0">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"],["collection_point_1","collection_point_1","collection_point_1","collection_point_1","collection_point_1","collection_point_2","collection_point_2","collection_point_2","collection_point_2","collection_point_2","collection_point_3","collection_point_3","collection_point_3","collection_point_3","collection_point_3"],["horsea","geodude","drowzee","eevee","goldeen","eevee","ekans","eevee","drowzee","krabby","abra","abra","bellsprout","bellsprout","bellsprout"],[119,225,213,234,59,44,95,195,44,91,101,81,156,262,389],[21,38,46,46,19,19,24,40,21,17,20,16,32,44,50],[4.62,18.16,25.17,5.33,10.83,9.82,5.2,6.02,41.36,5.4,17.18,25.94,5.85,5.42,3.4],["extra_small","normal","normal","normal","extra_small","extra_large","normal","normal","extra_large","normal","normal","extra_large","extra_large","extra_large","normal"],[0.29,0.4,0.85,0.3,0.54,0.34,1.93,0.28,1.09,0.38,0.85,1,0.8,0.82,0.66],["extra_small","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal"],["bubble","tackle","pound","tackle","mud_shot","tackle","acid","tackle","confusion","bubble","zen_headbutt","zen_headbutt","acid","acid","vine_whip"],["bubble_beam","rock_slide","psychic","body_slam","horn_attack","dig","gunk_shot","swift","psyshock","vice_grip","shadow_ball","shadow_ball","sludge_bomb","sludge_bomb","wrap"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>sheet<\/th>\n      <th>species<\/th>\n      <th>combat_power<\/th>\n      <th>hit_points<\/th>\n      <th>weight_kg<\/th>\n      <th>weight_bin<\/th>\n      <th>height_m<\/th>\n      <th>height_bin<\/th>\n      <th>fast_attack<\/th>\n      <th>charge_attack<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[3,4,5,7]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

But what about the February, March etc pokemon collection data? Now we have the `read_and_combine_sheets` function we can easily iterate over a list of paths to different workbooks, and row bind the lot:


```r
pokemon_monthly_collections <- fs::dir_ls( #collect all the path names 
  path = "data", regex = "pokemon_2019\\d{2}\\.xlsx$")  %>% 
  purrr::map_dfr(
    .f = read_and_combine_sheets #only one input so no need for ~, () or .x
    , .id = "workbook_path" #name of id column, value taken from .x
    )
```

Note that now we get two id columns, one for the workbook path and one for the sheet name, and there are now 45 rows, since each of the 3 workbooks contains 3 sheets of 5 rows of data.

```r
DT::datatable(data = pokemon_monthly_collections)
```

<!--html_preserve--><div id="htmlwidget-f6d35036bb7fba146f3c" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-f6d35036bb7fba146f3c">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45"],["data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201901.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201902.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx","data/pokemon_201903.xlsx"],["collection_point_1","collection_point_1","collection_point_1","collection_point_1","collection_point_1","collection_point_2","collection_point_2","collection_point_2","collection_point_2","collection_point_2","collection_point_3","collection_point_3","collection_point_3","collection_point_3","collection_point_3","collection_point_1","collection_point_1","collection_point_1","collection_point_1","collection_point_1","collection_point_2","collection_point_2","collection_point_2","collection_point_2","collection_point_2","collection_point_3","collection_point_3","collection_point_3","collection_point_3","collection_point_3","cp_1","cp_1","cp_1","cp_1","cp_1","cp_2","cp_2","cp_2","cp_2","cp_2","cp_3","cp_3","cp_3","cp_3","cp_3"],["horsea","geodude","drowzee","eevee","goldeen","eevee","ekans","eevee","drowzee","krabby","abra","abra","bellsprout","bellsprout","bellsprout","magikarp","krabby","drowzee","exeggute","horsea","goldeen","drowzee","bellsprout","jigglypuff","drowzee","eevee","eevee","chansey","bellsprout","drowzee","drowzee","horsea","cubone","magikarp","drowzee","goldeen","dratini","dratini","drowzee","drowzee","bulbasaur","krabby","exeggute","hypno","gastly"],[119,225,213,234,59,44,95,195,44,91,101,81,156,262,389,23,209,245,449,56,122,159,628,349,74,108,572,328,433,128,294,53,489,10,284,400,298,332,73,249,135,76,488,471,236],[21,38,46,46,19,19,24,40,21,17,20,16,32,44,50,10,29,52,67,15,26,40,68,119,28,30,74,291,59,38,54,14,64,10,54,53,42,44,26,50,29,18,67,66,30],[4.62,18.16,25.17,5.33,10.83,9.82,5.2,6.02,41.36,5.4,17.18,25.94,5.85,5.42,3.4,6.98,3.28,38.46,3.5,9.65,20.77,31.68,3.84,3.57,38.48,5.58,7.97,39.74,6.67,20.73,31.05,5.1,5.75,9,19.51,15.93,4.4,4.75,45.34,11.96,10.09,8.05,3.64,93,0.07],["extra_small","normal","normal","normal","extra_small","extra_large","normal","normal","extra_large","normal","normal","extra_large","extra_large","extra_large","normal","extra_small","normal","normal","extra_large","normal","extra_large","normal","normal","extra_small","normal","normal","normal","normal","extra_large","extra_small","normal","extra_small","normal","normal","extra_small","normal","extra_large","extra_large","extra_large","extra_small","extra_large","normal","extra_large","normal","extra_small"],[0.29,0.4,0.85,0.3,0.54,0.34,1.93,0.28,1.09,0.38,0.85,1,0.8,0.82,0.66,0.78,0.34,1.13,0.47,0.43,0.67,1.01,0.78,0.42,1.05,0.29,0.53,1.17,0.84,0.78,0.8,0.35,0.4,0.81,0.8,0.59,2.08,1.99,1.16,0.62,0.8,0.46,0.49,1.76,1.09],["extra_small","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","normal","extra_small","normal","normal","normal","normal","normal"],["bubble","tackle","pound","tackle","mud_shot","tackle","acid","tackle","confusion","bubble","zen_headbutt","zen_headbutt","acid","acid","vine_whip","splash","mud_shot","confusion","confusion","bubble","peck","pound","vine_whip","pound","pound","tackle","tackle","pound","acid","confusion","confusion","bubble","rock_smash","splash","pound","peck","dragon_breath","dragon_breath","confusion","confusion","tackle","bubble","confusion","confusion","lick"],["bubble_beam","rock_slide","psychic","body_slam","horn_attack","dig","gunk_shot","swift","psyshock","vice_grip","shadow_ball","shadow_ball","sludge_bomb","sludge_bomb","wrap","struggle","water_pulse","psyshock","psychic","bubble_beam","water_pulse","psybeam","sludge_bomb","disarming_voice","psybeam","body_slam","swift","dazzling_gleam","power_whip","psyshock","psybeam","flash_cannon","bulldoze","struggle","psybeam","aqua_tail","aqua_tail","twister","psybeam","psychic","sludge_bomb","water_pulse","psychic","psychic","sludge_bomb"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>workbook_path<\/th>\n      <th>sheet<\/th>\n      <th>species<\/th>\n      <th>combat_power<\/th>\n      <th>hit_points<\/th>\n      <th>weight_kg<\/th>\n      <th>weight_bin<\/th>\n      <th>height_m<\/th>\n      <th>height_bin<\/th>\n      <th>fast_attack<\/th>\n      <th>charge_attack<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[4,5,6,8]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


## Function 3: `map2_dfc`
Now we look at an example of data scattered over a few specific cells. This might be received as the return of a form created in a more human readable rather than machine readable format. In the pet form example below the data we want is only in cells **B2**, **D5** and **E8**. We want to end up with a dataframe of the variables "Name", "Age" and "Species".

![](image/pet_forms.png)

### `map2_dfc`
This function is an example of iterating over a pair of lists and returning a column bound dataframe. For our pet forms example the two lists are the character vectors of the cells and the names that go with them. The three pairs of elements to be iterated over are ("B2", "Name"), ("D5","Age"), and ("E8", "Species"). 


```r
cells <- c("B2", "D5", "E8")
col_names <- c("Name", "Age", "Species")
```

The function `cells_to_rows` below iterates over `read_excel` reading each of the three cells from the worksheet, applying the corresponding column name as it goes. It takes three character or character vector inputs, `path`, `cells`, and `col_names`.


```r
cells_to_rows <- function(path, cells, col_names){
  purrr::map2_dfc(
    .x = cells
    , .y = col_names
    , .f = ~ readxl::read_excel(
      path = path
      , range = .x
      , col_names = .y
    ) 
  )
}
```

Now we can iterate this over all the pet form workbooks, specifying the paths using regex as before. Note below we use `.x` in the `path` argument in the `cells_to_rows` function to refer to the vector of paths piped to `purrr::map_dfr` from `fs::dir_ls`. 

```r
cells <- c("B2", "D5", "E8")
col_names <- c("Name", "Age", "Species")

all_pet_forms <- fs::dir_ls(
  path = "data", regex = "pet_form_\\d\\.xlsx$")  %>% 
  purrr::map_dfr(
    .f = ~ cells_to_rows(path = .x, cells = cells, col_names = col_names)
    , .id = "path"
    )
```

<table class="table" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> path </th>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:right;"> Age </th>
   <th style="text-align:left;"> Species </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> data/pet_form_1.xlsx </td>
   <td style="text-align:left;"> Tiddles </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:left;"> cat </td>
  </tr>
  <tr>
   <td style="text-align:left;"> data/pet_form_2.xlsx </td>
   <td style="text-align:left;"> Woof </td>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:left;"> dog </td>
  </tr>
  <tr>
   <td style="text-align:left;"> data/pet_form_3.xlsx </td>
   <td style="text-align:left;"> Hammy </td>
   <td style="text-align:right;"> 0.5 </td>
   <td style="text-align:left;"> hamster </td>
  </tr>
  <tr>
   <td style="text-align:left;"> data/pet_form_4.xlsx </td>
   <td style="text-align:left;"> Toothless </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:left;"> dragon </td>
  </tr>
</tbody>
</table>

If you're thinking "what if we had many worksheets and many workbooks of such data?" then I direct you to the rest of the [DfT R Cookbook chapter 3.6](https://departmentfortransport.github.io/R-cookbook/data-import.html#non-rectangular-data---many-worksheets---single-workbook)

## Function 4: `map`
This example shows how to split a dataframe into many outputs and then write those to separate text files. We use the dataframe created above **monthly_fruit_consumption**, which contains a row per fruit per month. We want to just collect the list of fruits for each month and write these to a text file  - say it's a shopping list for each month.

```r
#create unique list/vector of things to iterate over from the month column
months <- unique(monthly_fruit_consumption$month)

# write function to work for one month, m
write_fruit_list <- function(df, m){ #takes dataframe and month
  df %>% 
    dplyr::filter(month == m) %>% #expects data to contain column named 'month'
    dplyr::select(fruit) %>% #expects data to contain a column named 'fruit'
    readr::write_delim( #write data and construct path and file name
      path = glue::glue('data/fruit_consumed_in_', m, '.txt') 
                       , col_names = TRUE)
}
```

Next iterate this function over the list of months.This writes three text files, each containing the fruits consumed that month.

```r
#iterate
purrr::map(
  .x = months
  , .f = ~ write_fruit_list(
    df = monthly_fruit_consumption
    , m = .x)
)
```

Read in one of the text files to have a look at the output:

```r
readr::read_delim(file = "data/fruit_consumed_in_May.txt"
                  , delim = " ") %>% 
  knitr::kable() %>% 
  kableExtra::kable_styling(full_width = F, position = "left")
```

<table class="table" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> fruit </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> gooseberry </td>
  </tr>
  <tr>
   <td style="text-align:left;"> guava </td>
  </tr>
</tbody>
</table>

## Any questions?


<img src="image/sad_butter_robot_2.png" width="300px" />


