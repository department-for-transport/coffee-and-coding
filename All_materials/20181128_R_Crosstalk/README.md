# Crosstalk: Shiny-like without Shiny

## This session

[Matt Dray](https://www.twitter.com/mattdray) of Government Digital Service (GDS) will re-run [his presentation](https://matt-dray.github.io/earl18-presentation/) about the R package [Crosstalk](https://rstudio.github.io/crosstalk/) from [the EARL 2018 conference](https://earlconf.com/2018/london/) and dip into the code behind his demos.

He'll also talk through [relevant Crosstalk memes from his blogpost](https://www.rostrum.blog/2018/09/12/crosstalk-memes/).

## Blurb

From [the EARL 2018 site](https://earlconf.com/2018/london/#matt-dray):

> Self-service interactive tools have great power to support decisions by policy-makers. Shiny apps are a natural fit for this, but it's not always easy to share them within the public sector. This is due to issues like a lack of server space, highly sensitive data and users who aren't R-savvy.
>
> We've approached this problem in the UK's Department for Education by sharing interactive HTML widgets – embeddable JavaScript visualisation libraries – within RMarkdown outputs. Interactivity is, however, limited because selections in one widget don’t impact the data presented in another.
>
> Joe Cheng's Crosstalk package overcomes this with shared data objects that react to user inputs, altering the content of multiple widgets on the fly.
>
> I'll explain how I used Crosstalk to develop a 'pseudo-app' for exploring schools data with the Leaflet (maps) and DT (tables) widgets inside the Flexdashboard framework and how I shared it easily with policy-making users as a static HTML file for exploration in the browser. (Note that this talk is restricted to published data and the content of this talk does not reflect or constitute official policy.)

## Crosstalk summary

Crosstalk allows inter-widget interactivity without the need for [Shiny](https://shiny.rstudio.com/). This means that [HTML widgets like Leaflet, DT and Plotly](https://www.htmlwidgets.org/) can interact with each other – selecting data in one of these widgets impacts the data presented in the others. There’s also a range of sliders and buttons to filter data across these widgets.

But Shiny can do all this already, so why bother with Crosstalk? Crosstalk doesn’t rely on a server; it works entirely in-browser. You can send an HTML file with Crosstalk-enabled widgets as an attachment via email, or store it in your shared drives. It also requires one extra line of code: create a dataframe object as usual, then create a *shared data* object from it.

Before – the interactive table and map can’t talk to each other:

```
data <- readRDS("data/some_data.RDS")  # get data
datatable(data)  # interactive table
leaflet(data) %>% addTiles() %>% addMarkers()  # interactive map
```

After – the interactive table and map can share filtering via the shared data object):

```
data <- readRDS("data/some_data.RDS")
shared <- SharedData$new(data) # this is the new line
datatable(shared)
leaflet(shared) %>% addTiles() %>% addMarkers()
```
See the links below for examples of what the output looks like in practice.

Also note that Crosstalk suffers from a number of limitations including that:

* the larger the number of data points, the slower the app – it's being rendered entirely by the browser
* it doesn't have anywhere near the functionality of Shiny – you can't use your selections to drive other calculations, for example
* only a select number of HTML widgets are compatible with Crosstalk
* while stable, the package hasn't been updated for a number of months



## Links

### Crosstalk documentation

* [Website](https://rstudio.github.io/crosstalk/)
* [GitHub repo](https://github.com/rstudio/crosstalk)
* [CRAN manual](https://cran.r-project.org/web/packages/crosstalk/crosstalk.pdf) and [details](https://cran.r-project.org/package=crosstalk)
* [Joe Cheng (cross)talking at rstudio::conf 2017](https://www.rstudio.com/resources/videos/linking-html-widgets-with-crosstalk/)

### Examples

* [Gapminder example](http://rstudio-pubs-static.s3.amazonaws.com/209203_02f14fea3274448bbbf8d04c99c6051b.html)
* Demo [without](https://rpubs.com/jcheng/dash1) and [with](https://rpubs.com/jcheng/dash2) Crosstalk

### EARL 2018

* [Matt's EARL 2018 presentation](https://matt-dray.github.io/earl18-presentation/) and [GitHub repo](https://github.com/matt-dray/earl18-presentation)
* [Matt's blog post about his Crosstalk talk](https://matt-dray.github.io/earl18-presentation/)
* Demos and [GitHub repo](https://github.com/matt-dray/earl18-crosstalk):
    - [Demo 1](https://matt-dray.github.io/earl18-crosstalk/01_leaflet.html) (just an interactive Leaflet map)
    - [Demo 2](https://matt-dray.github.io/earl18-crosstalk/02_leaflet-flexdash.html) (an interactive Leaflet map in a flexdashboard)
    - [Demo 3](https://matt-dray.github.io/earl18-crosstalk/03_leaflet-flexdash-dt.html) (an interactive Leaflet map and an interactive DT data table in a flexdashboard, no Crosstalk)
    - [Demo 4](https://matt-dray.github.io/earl18-crosstalk/04_leaflet-flexdash-dt-crosstalk.html)
