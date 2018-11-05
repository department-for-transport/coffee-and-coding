install.packages('hexSticker')
library(hexSticker)

#set path to image, could be a url
imgpath <- "images/coffee_pipe_steam.png"
sticker(subplot = imgpath
        , s_x = 1.05
        , s_y = 1.05
        , s_width = 0.7 #leave s_height blank to maintain aspect ratio
        , package = " " #leave blank, or separate words with 6 spaces to accommodate steam ()
        , p_x = 0.975                     
        , p_y = 1.385
        , p_color = "#006853" #package (title) text colour
        , p_family = "Aller_Rg"
        , p_size = 5
        , h_size = 1.2
        , h_fill = "#99D6DD" #hex background colour
        , h_color = "#006853" #hex edge colour
        # , spotlight = TRUE
        # , l_x = 1
        # , l_y = 0.8
        # , l_width = 3
        # , l_alpha = 0.3
        , url = "coffee.coding@dft.gov.uk"
        , u_x = 1
        , u_y = 0.08
        , u_color = "#006853" #url text colour
        , u_family = "Aller_It"
        , u_size = 2
        , filename = "images/c&c_dft_hex_symbol.png")

#DfT colours used in publications
#006853 - darkest green
#66A498 - middle green
#D25F15 - darkest peach
#E49F73 - 2nd darkest peach
#C99212 - darkest mustard
#E9D3A0 - middle mustard
#0099A9 - darkest teal
#99D6DD - middle teal

#Other shades
#66C2CB - 2nd darkest teal
#AEE0E5 - 2nd lightest teal
#CCEBEE - lightest teal
#0082CA - darkest blue (for hyperlinks/emails)
#B3D2CB - 2nd lightest green
#CCE1DD - lightest green

#https://github.com/mkearney/hexagon
## install devtools package if it's not already
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

## install dev version of hexagon from github
devtools::install_github("mkearney/hexagon")

## load rtweet package
library(hexagon)
