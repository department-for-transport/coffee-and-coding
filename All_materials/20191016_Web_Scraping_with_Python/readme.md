## Webscraping with Python
### Greg Williams, Office of Road and Rail

#### gregory.williams@orr.gov.uk

These notes are intended to show the possibilities for webscraping within Python.

There are two possible approaches to webscraping.
1.    **Direct webscraping**: Get the html returned by the web request, extract the information from relevant tags and then parse it into a more useable form.
2.    **Indirect webscraping**: Post a GET request to access an API to return data preformatted.

### Direct Webscraping example: RME Webscrape
#### Two .py files 
RME Webscrap 
Combine Data

#### Three subfolders
1_Read_ME_Instructions: TXT. file with instructions for users
2_Route_and_times_metadata: Excel file containing metadata
3_Data_goes_here: Destination folder for output

#### Execution path
_('gettingquerydata')_ reads routes, dates, time and search_type metadata  from excel spreadseet, which it uses to define the search type  _('getdaysahead')_, which is used to set the number of days ahead to search for.  This combined data is passed into a list of lists. 
_('getdatetimesinfo')_ is used to determine the date and the days of the week they fall on based on the number of days ahead.' If the application is run on a Friday the code loops three times incrementing day by one, to collect data for the weekend as well.  
_('createddataset')_ then uses _('generateurl')_ to create complete URLs from concatinating the root of the URL with the relevant metadata information.  This function has various cases to cover searches for all or one TOC as well as a date x days ahead from the date of execution or a fixed number of days ahead.
This returns a list which is passed to _('extractwebdata')_  This loops through the list of URLs and makes requests to the NR server.  The returned html contains JSON within specific tags which is parsed by the library Beautiful Soup to extract the JSON data, which is then stored in a list, with some metadata added as JSON nodes.  
This list is then passed to _('processjson')_ which converts the JSON data into CSV format.  This function also converts the CSV to a pandas data frame to check for duplicated data and it is then converted again to CSV.
The CSV is passed to _('tidyupfiles')_ which uses _('get daily data')_ to read the CSV files from the "data goes here folder" into a pandas dataframe.  _('get_appended_data')_ reads the previously created CSV data into a dataframe which _('combine_daily_and_appended_data')_ then combines.
_('clean up')_ deletes any files that do not have the current date.

#### Key Python Libraries for this application
+ [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/bs4/doc/)
+ [Urllib](https://docs.python.org/3/howto/urllib2.html)
+ [urllib request](https://docs.python.org/3/library/urllib.request.html)
+ [JSON](https://realpython.com/python-json/)



### Indirect Webscraping example: NRE_XML_Parsing
#### Two .py files 
main 
Combine Data

#### No subfolders

#### Execution path
_('main')_ calls passed API credentials to _(getnrxml)_  which uses _(requesttoken)_ to get a session key.  _(requesttoken)_ makes a POST request whose response has the token element extracted from it in JSON format.  This token, along with API credentials, is passed to _(extractNREXML)_ to make a GET request which then returns a raw XML file.  _(xmltocsv)_ then converts the XML to a CSV dataset, which is then turned by _(csvtodf)_ into a dataframe which then exported to Excel

#### Key Python Libraries for this application
+ [urllib request](https://docs.python.org/3/library/urllib.request.html)
+ [csv](https://docs.python.org/3/library/csv.html#)


Happy Scraping!




