# NewsArticleClustering

The scripts in this repository represent a proof of concept in clustering news articles from RSS feeds. 

# Usage 

The main `tm_analysis.R` script starts the analysis, and calls out to `process_feeds.py` to fetch the article feeds before performing the clustering analysis. Additional utility functions to manipulate the resulting JSON and parse in the correct metadata to the VCorpus object in tm are included in `processing_utils.R` 

# Dependencies:

Python: 

* requests
* BeautifulSoup
* feedparser

R: 

* jsonlite
* tm
* SnowballC
* proxy
* dendextend

# Example Visualisations:

An example of the clusters formed from 475 articles published over a 4 day period is shown below where the leaf nodes are coloured according to their source, with blue corresponding to BBC News, green to The Guardian, and indigo to The Independent. The utility function `plot_dend` in `processing_utils.R` was used to make the figures. 

![GitHub Logo](/Article_Clustering_full.png)

Zooming in on a cluster of articles around Storm Desmond and the flooding in Cumbria in Dec 2015.

![GitHub Logo](/Article_subsection_flooding.png)

