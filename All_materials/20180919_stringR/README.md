Coffee & Coding: stringr & regex with pirates
---------------------------------------------
#### *Tamsin Forbes*
#### *2018-09-19 [Talk Like a Pirate Day]*

[Download folder](https://minhaskamal.github.io/DownGit/#/home?url=https://github.com/departmentfortransport/coffee-and-coding/tree/master/All_materials/20180919_stringR)

Intro
-----

For this meetup, in honour of **Talk Like a Pirate Day**, I will be channeling the accent of my favourite pirate; the Dread Pirate Roberts played by Carey Elwes in the movie of the Princess Bride. Apologies in advance if I do not do his posh English accent justice.

![](images/dread_pirate_roberts_cliffs_of_insanity.png)

We'll be using some pirate data; as in data collected on pirates and their characteristics (rather than data collected via contravention of copyright). The pirate data used below has been augmented by me with extra made up data, but the original pirate datasets are availble within the `yarrr` package.

Housekeeping
------------
If you are reading this you are reading the README.md file which will give you the text of the talk and the 
code but none of the code output. To view the code output as well see the rmarkdown output [pirate_stringR_demo.html](https://github.com/tamsinforbes/coffee-and-coding/tree/master/20180919_stringR/pirate_stringR_demo.html), to see the original rmarkdown file and run the code yourself clone this repo (which includes the data) and work through **pirate_stringR_demo.Rmd**.

If you do not already have the packages used below installed you will need to do so with `install.packages('package_name')`. (If you are running this on DfT network you won't need to install any packages).

Throughout the code below I have been inconsistent in explicitly stating the namespace or package that function comes from, that is, sometimes I have used `package::function()` and sometimes just the `function()`. To get info on a function type `?function_name` into the console, this will also tell you what packages have that function.

The links section at the bottom has several links to more info on `regex`, `stringr` and more...

What the heck is regex?
-----------------------

Very briefly, `regex` is short for 'regular expression'. It is used for matching a particular search pattern or set of search patterns within a character string. This is a versatile way to search a messy dataset where you might have mixtures of lower and upper case, variations on spelling, punctuation, digits etc. If you can work out what the strings you want have in common, then you can find them all! The `regex` rules that the `stringr` package uses are pretty universal/language agnositic.

I'm going to start with a use case below and show how I used `stringr` to clean up a messy data set and then demo a few other `stringr` functions.

The scenario
------------

We live in times when many pirates roam the seas, we require information, probably for tax purposes, and what better way to get these data, than to send out a questionaire via email/carrier pigeon/dolphin/morse code in the form of an MS Excel spreadsheet to be free text filled in.

The returns are a nightmarish goobledegook of variations spread over several sheets, with different formats for dates and times.

![](images/pirate_data_xlsx.png)

Read in data
------------

So the first task is to read everything in as characters, since with so many variants, type guessing cannot cope.

There are a few ways of doing this, the method below reads in each sheet from the solitary .xlsx and row binds the data into one dataframe.

```r
library(readxl) 
library(tidyverse)
```

```r
path <- "data/pirate_data.xlsx" #set path to .xlsx
pirate_data <- path %>% 
  readxl::excel_sheets() %>% #pipe path into excel_sheets() to read all sheets
  purrr::set_names() %>% #collect sheet names from the .xlsx
  purrr::map_df( #iterate instructions on how to read in sheets and row bind
    ~ readxl::read_xlsx(path = path #as set above 
                        , sheet = .x #iterate over sheet vector from set_names()
                        , col_types = "text" #specify all cols as text
                        , trim_ws = TRUE) #trim white space if any
    , .id = "sheet"  #add id column/name
  )

head(pirate_data)
```

Clean data - dates
------------------

The date and time variables are the biggest headache here. Since we allowed free text input our pirates have entered the information in every possible way. We have forward slashes, dashes, datetimes, decimals, hh:mm:ss, hh:mm, and my personal Excel favourite; the number of days since 30th December 1899. To be able to use the dates and times we need to get them cleaned up and converted to proper datetime format, complete with time zone.

Let's start using the `stringr` package to identify the different date formats. Our main workhorse here is `stringr::str_detect` used inside `dplyr::filter` `r library(stringr)`

Let's filter for a forward slash anywhere in a string in the rdate column 

```r
pirate_data %>% filter(str_detect(string = rdate, pattern = "/"))
```

We know there are two digits in between two forward slashes, we can use the special character `\d` to match digits. To represent the special character we actually have to type `\\d`. For example, to match a pattern like "/09/" we type

```r
pirate_data %>% filter(str_detect(string = rdate, pattern = "/\\d\\d/"))
``` 

That could get tedious if we have many digits, so we can specify the exact number, for example to match a pattern like "19/09/2018" we type 

```r
pirate_data %>% filter(str_detect(string = rdate, pattern = "\\d{2}/\\d{2}/\\d{4}"))
```

All of the above match the pattern anywhere in the string, now lets specify position by achoring the start and end with `^` and `$`

```r
pirate_data %>% filter(
  str_detect(string = rdate, pattern = "^\\d{2}/\\d{2}/\\d{4}$"))
```

Great, we've identified all the patterns of exactly 2digits/2digits/4digits

Let's count these and compare to the count of those with the simple pattern "/"

```r
pirate_data %>% filter(str_detect(string = rdate, pattern = "/")) %>% count() ==
  pirate_data %>% filter(
    str_detect(string = rdate, pattern = "^\\d{2}/\\d{2}/\\d{4}$")) %>% count()
```

The results of the specific search must at least be a subset of the simple search, since the count is the same we conclude that both searches return exactly the same results. This is important if it is necessary to optimise a search. While both will check every character of the strings that don't match, the simple search will stop at the third character of the strings that do match, as this is the first occurance of "/". The specific search will still have to check every character.

Now we know that all of the dates contianing "/" are of the form "09/19/2018". (Arrr!)

We can do a similar thing matching for "-" in the rdate column

```r
pirate_data %>% filter(str_detect(string = rdate, pattern = "-")) %>% head()
```

Here we've got two types, some are just dates, but some are datetimes. So we can make the search more specific and check that a simple "-" search is sufficient;

```r
pirate_data %>% filter(str_detect(string = rdate, pattern = "-")) %>% count() ==
pirate_data %>% filter( #match patterns like "2018-09-19", anchoring both ends
  str_detect(string = rdate, pattern = "^\\d{4}-\\d{2}-\\d{2}$")) %>% count() +
pirate_data %>% filter( #match patterns like "2018-09-19T" anchoring start only
  str_detect(string = rdate, pattern = "^\\d{4}-\\d{2}-\\d{2}T")) %>% count()
```

The counts add up, so again the simple search is sufficient and we don't have any other date types using "-" such as dd-mm-yyyy.

So, you get the idea - we continue to identfiy all the subsets of dates in rdate and check how best to match them.

Now we can convert them to proper date type. Below we use another `stringr` function `stringr::str_sub` which lets us subset a string specifying the index of the start and end characters. We need this because some of the dates are datetimes and we only want the date part (the first 10 or 5 characters here) for the new date column. We also use various `lubridate` date conversion functions (`dmy`, `ymd`, `as_date`) to convert the different formats, and the ever useful `dplyr::case_when` to determine what to do with each subset.

```r
library(lubridate)
```

```r
pirate_data <- pirate_data %>% dplyr::mutate(
  `date` = dplyr::case_when(
    #convert patterns like "19/09/2018"
    str_detect(string = rdate, pattern = "/") ~ lubridate::dmy(rdate)
    #convert patterns like "2018-09-19" and "2018-09-19T..." 
    , str_detect(string = rdate, pattern = "-") ~ lubridate::ymd(
      str_sub(string = rdate, start = 1, end = 10))
    #convert patterns like "42253" and "42253.63542..."
    , str_detect(rdate, "^\\d{5}") ~ lubridate::as_date(
      as.numeric(str_sub(rdate, 1, 5)), origin = "1899-12-30")
    #specify what to do with the remaining unmatched rows
    #NB the type of NA must match the type of the rest, hence 
    , TRUE ~ lubridate::ymd(NA)
  )
) 
```

We got some scary warnings so let's check the NAs are as expected, using `janitor::tabyl`, a tidyverse version of `base::table` 

```r
library(janitor) tabyl(filter(pirate_data, is.na(date)), date, rdate)
``` 

Clean data - times 
------------------
To cut a long story short we do the same with the rtime column. We use `stringr::str_detect` to identufy the various proper subsets and then use `hms` package for convertinng times (`hms` and `as.hms`. \[In my experience `lubridate` does dates and datetimes well, but times alone I found tricky (Freudian slip)\]. Ultimately we want a single variable of datetime, so we'll go back to `lubridate` shortly.

The various time formats are hh:mm:ss, hh:mm, number of seconds since midnight (some greater than 1, some in scientific notation), datetime and NAs

```r
pirate_data$rtime[c(1, 4, 5, 6, 7, 8, 12, 19, 20, 23, 24)]
```

The 'number of seconds since midnight' type has to be converted to a fraction of a day and rounded to the nearest second, as `hms::hms` expects a whole number of seconds to work correctly.

We use a new special character below `+` to indicate 'one or more' 

```r
pirate_data <- pirate_data %>% dplyr::mutate(
  time = dplyr::case_when(
    #convert patterns in scientific notation 
    str_detect(rtime, "E-\\d$") ~ hms::hms(
      round(as.numeric(rtime) * 24 * 60 * 60, 0))
    #convert patterns like "42887.2...", with one or more digits after the .
    #we don't want to include any that are just dates
    , str_detect(rtime, "^\\d{5}\\.\\d+$") ~ hms::hms(
      round(
        as.numeric(
          str_sub(rtime
                  ,start =  6
                  ,end = str_length(rtime)))
        * 24 * 60 * 60
        , 0))
    #convert patterns like "0.326532..."
    , str_detect(rtime, "^0\\.\\d+$") ~ hms::hms(
      round(as.numeric(rtime) * 24 * 60 * 60, 0))
    #convert patterns like "1.326532..." and subtract the 1 day
    , str_detect(rtime, "^1\\.\\d+$") ~ hms::hms(
      round(((as.numeric(rtime)) - 1) * 24 * 60 * 60, 0))
    #convert patterns like "2.326532..." and subtract the 2 days
    , str_detect(rtime, "^2\\.\\d+$") ~ hms::hms(
      round(((as.numeric(rtime)) - 2) * 24 * 60 * 60, 0))
    #convert patterns like "hh:mm"
    , str_detect(rtime, "^\\d{2}:\\d{2}$") ~ hms::as.hms(
      str_c(rtime, ":00"))
    #convert patterns like "hh:mm:ss"
    , str_detect(rtime, "^\\d{2}:\\d{2}:\\d{2}$") ~ hms::as.hms(
      rtime)
    #convert datetime patterns like "yyyy-mm-ddT..."
    , str_detect(rtime, "^\\d{4}-\\d{2}-\\d{2}T") ~ hms::as.hms(
      str_sub(rtime,
              start = 12
              ,end = 19))
    #specify what to do with the remaining unmatched rows
    #NB the type of NA must match the type of the rest, hence 
    , TRUE ~ hms::hms(NA) 
  )
)

```

And double check that the NAs are as expected

```r
tabyl(filter(pirate_data, is.na(time)), time, rtime)
```

Hooray we have proper dates & times lets make datetimes!!!
----------------------------------------------------------

Now we can join the cleaned dates and times together to make a datetime column and code for the timezone using `lubridate::ymd_hms` and `stringr::str_c` which concatenates strings (default is no separator)

``` r
pirate_data <- pirate_data %>% dplyr::mutate(
  datetime = dplyr::case_when(
    #convert the columns with no date to NA first
    is.na(date) ~ lubridate::ymd_hms(NA)
    #convert the columns with no time (but will have a date), set time to midnight
    , is.na(time) ~ lubridate::ymd_hms(str_c(date, "T00:00:00")
                            , tz =  "UTC")
    #convert the remaining (non-NA) dates and times
    , TRUE ~ lubridate::ymd_hms(str_c(date, "T",  time)
                      , tz =  "UTC")
)
)
```

``` r
pirate_data %>% select(rdate, rtime, date, time, datetime) %>% glimpse()
```

A note on `lubridate` timezones
-------------------------------

`lubridate` has a long list of timezones to choose from, the full character vector can be viewed with `OlsonNames()`. We can use `stringr::str_subset` to have a look at a few

``` r
OlsonNames() %>% str_subset("America/P")
OlsonNames() %>% str_subset("Ber")
OlsonNames() %>% str_subset("Pacific/E")
```

What else can `stringr` & regex do?
-----------------------------------

Now let's move on from the mindless tedium of sorting out dates and times and look at some other neat features of `stringr`. For this we'll be using the *expression* column, which records the pirates's preferred exclamation and spelling.

We'll use `janitor::tabyl` again with a few more features (just to show it has more uses than `base::table`)

``` r
pirate_data %>%
  tabyl(sheet, expression) %>% #pick columns to tabulate
  adorn_totals("col") %>% #add column of row totals
  adorn_percentages("row") %>% #add row percentages (by sheet)
  adorn_pct_formatting(digits = 2) %>% #specify pct to 2dp
  adorn_ns() %>% #add the actual numerical count (n's) by sheet
  adorn_title() #add title - the column name
```

Let's say we are linguists attempting to document piratical expressions, and we are particularly interested in determining origins by excessive use of dipthongs (or something)

``` r
pirate_exp <- pirate_data %>% select(expression) %>% distinct(expression)
```

Look for patterns using or `|`

``` r
pirate_exp %>% filter(str_detect(string = expression, pattern = "oa|oy"))
```

Look for matches with between *n* and *m* occurances of a pattern using `n,m`

``` r
pirate_exp %>% filter(str_detect(string = expression, pattern = "o{3,4}"))
```

Look for matches with a pattern preceded by another pattern

``` r
pirate_exp %>% filter(str_detect(string = expression, pattern = "(?<=ooa)r"))
```

Count the number of matches in a string

``` r
pirate_exp %>% mutate(
  count_of_oo = str_count(string = expression, pattern = "oo")
  , count_of_rrg = str_count(string = expression, pattern = "rrg")
  , count_of_r = str_count(string = expression, pattern = "r")
)
```

Packages recap
--------------

`stringr` for string manipulation

`lubridate` for dates and datetimes (with timezone)

`hms` for times

`janitor` for quick and easy read 'adorned' tables

`dplyr` for data wrangling

`purrr` for iterating functions over vector inputs

`readxl` for manipulating .xls and .xlsx

Links
-----

Find out more with the `stringr` Cheat Sheet here <https://www.rstudio.com/resources/cheatsheets/#stringr> (many other cheat sheets also available at this link)

For more on `regex` in general see here <https://github.com/zeeshanu/learn-regex/blob/master/README.md>

For some history on `regex` see here <https://en.wikipedia.org/wiki/Regular_expression>

For playing/testing `regex` search patterns try this tool here <https://regexr.com/>

For more on 'tidy data' see here <https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html>

For more on getting what you want out of speadsheets and into R <https://nacnudus.github.io/spreadsheet-munging-strategies/index.html>

Thank you for your kind attention
---------------------------------

Any questions/suggestions please email <coffee.coding@dft.gov.uk>

##### *fin*
