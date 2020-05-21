
# Correspondence OCR and PQ Classification web app

A flask web app that can sort parliamentary questions into responding units.

## Download and Installation

The repo contains pretty much everything you need

### /model

Within 'model' are all the required trained models, and a number of other required data structures that we pickled


### /static

All the javascript and css for the front end (required by flask)

### /templates

The HTML for the front end

### app.py
Loads our models and does all the route handling

### neural_net.py
Contains our NeuralNet class, which contains the neural net and has prediction methods



### check_api.py
Contains a get_pqs function which gets the most recent PQs from the parliament written question API
http://explore.data.parliament.uk/?learnmore=Commons%20Written%20Questions



## To run the app:

python app.py
